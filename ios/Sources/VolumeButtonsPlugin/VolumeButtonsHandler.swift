/*
 * @capacitor-community/volume-buttons plugin
 *
 * This software contains code derived from or inspired by the following sources:
 *
 * 1. Original code from the VolumeButtonHandler, licensed under the Apache License, Version 2.0.
 *    - Original code URL: https://github.com/CipherBitCorp/VolumeButtonHandler
 *    - Original code authors: CipherBit Corp.
 *    - Original code license: Apache License, Version 2.0
 *
 * 2. Modifications made by Alex Ryltsov to the original code:
 *    - change some access modifiers for variables
 *    - removed sessionContext variable and its usage
 *    - changed MPVolumeView and initialization and the way it is inserted/added to the parent view
 *    - minor updates to AVAudioSession outputVolume KVO changes observation/handling
 *    - changed setSystemVolume to use the existing MPVolumeView instance instaed of re-creating it
 *    - replaced upBlock and downBlock with the single handlerBlock
 *    - changed to report volume direction change only
 *    - added workaround to restart the audio session when the app returns from the background to foreground
 *    - other minor fixes and improvements
 *
 * The original code and any modifications are subject to the terms and conditions of the Apache License,
 * Version 2.0. A copy of the Apache License, Version 2.0 can be found at http://www.apache.org/licenses/LICENSE-2.0.
 *
 * You may obtain a copy of the Apache License, Version 2.0 along with this software.
 * If not, see http://www.apache.org/licenses/LICENSE-2.0.
 */

import Foundation
import MediaPlayer
import AVFoundation
import AVFAudio

public typealias VolumeButtonBlock = (_ direction: String) -> Void

public class VolumeButtonsHandler: NSObject {

    private var initialVolume: CGFloat = 0.0
    private var session: AVAudioSession?
    private var volumeView: MPVolumeView?
    
    private var appIsActive = false

    private var disableSystemVolumeHandler = false
    private var isAdjustingVolume = false
    private var exactJumpsOnly: Bool = false
    
    private var sessionOptions: AVAudioSession.CategoryOptions?
    private var sessionCategory: String = ""
    
    private var observation: NSKeyValueObservation? = nil
    private let tag = "VolumeButtonHandler"
    
    static let maxVolume: CGFloat = 0.95
    static let minVolume: CGFloat = 0.05
    
    public var handlerBlock: VolumeButtonBlock?
    public var currentVolume: Float = 0.0
    public var isStarted = false
    
    override public init() {
        appIsActive = true
        sessionCategory = AVAudioSession.Category.playback.rawValue
        sessionOptions = AVAudioSession.CategoryOptions.mixWithOthers

        volumeView = MPVolumeView(
            frame: CGRect(
                x: CGFloat.infinity,
                y: CGFloat.infinity,
                width: 0,
                height: 0
            )
        )
        
         if let window = UIApplication.shared.windows.first, let view = volumeView {
            window.insertSubview(view, at: 0)
        }
        
        volumeView?.isHidden = true
        exactJumpsOnly = false
    }
    
    deinit {
        stopHandler()
        
        if let volumeView = volumeView {
            DispatchQueue.main.async {
                volumeView.removeFromSuperview()
            }
        }
    }
    
    public func startHandler(_ disableSystemVolumeHandler: Bool) {
        self.setupSession()
        volumeView?.isHidden = false
        self.disableSystemVolumeHandler = disableSystemVolumeHandler
    }

    public func stopHandler() {
        guard isStarted else { return }
        isStarted = false
        volumeView?.isHidden = false
        self.observation = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setupSession() {
        guard !isStarted else { return }
        isStarted = true
        self.session = AVAudioSession.sharedInstance()
        setInitialVolume()
        do {
            try session?.setCategory(AVAudioSession.Category(rawValue: sessionCategory), options: sessionOptions!)
            try session?.setActive(true)
        } catch {
            print("Error setupSession: \(error)")
        }
        
        observation = session?.observe(\.outputVolume, options: [.new, .old, .initial]) { [weak self] session, change in
            guard let newVolume = change.newValue,
                  let oldVolume = change.oldValue,
                  let self = self else {
                return
            }
            
            if !appIsActive {
                // NOTE: Probably control center, skip blocks
                debugPrint("app not active, skip")
                return
            }
            
            let difference = abs(newVolume - oldVolume)
            
            if isAdjustingVolume {
                isAdjustingVolume = false
                return
            }
            
            debugPrint("\(tag) Old Vol:%f New Vol:%f Difference = %f", oldVolume, newVolume, difference)
            
            if exactJumpsOnly && difference < 0.062 && (newVolume == 1.0 || newVolume == 0.0) {
                debugPrint("\(tag) Using a non-standard Jump of %f (%f-%f) which is less than the .0625 because a press of the volume button resulted in hitting min or max volume", difference, oldVolume, newVolume)
            } else if exactJumpsOnly && (difference > 0.063 || difference < 0.062) {
                debugPrint("\(tag) Ignoring non-standard Jump of %f (%f-%f), which is not the .0625 a press of the actually volume button would have resulted in.", difference, oldVolume, newVolume)
                setInitialVolume()
                return
            }
            
            var direction: String
            if newVolume == 1.0 || newVolume > oldVolume {
                direction = "up"
            } else {
                direction = "down"
            }
            currentVolume = newVolume
            
            if !disableSystemVolumeHandler {
                // NOTE: Don't reset volume if default handling is enabled
                handlerBlock?(direction)
                return
            }
            
            // NOTE: Reset volume
            setSystemVolume(initialVolume)
            handlerBlock?(direction)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruped(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidChangeActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidChangeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        volumeView?.isHidden = !disableSystemVolumeHandler
    }

    func useExactJumpsOnly(enabled: Bool) {
        exactJumpsOnly = enabled
    }
    
    @objc func audioSessionInterruped(notification: NSNotification) {
        guard let interruptionDict = notification.userInfo,
              let interruptionType = interruptionDict[AVAudioSessionInterruptionTypeKey] as? UInt else {
            return
        }
        switch AVAudioSession.InterruptionType(rawValue: interruptionType) {
        case .began:
            debugPrint("Audio Session Interruption case started")
        case .ended:
            print("Audio Session interruption case ended")
            do {
                try self.session?.setActive(true)
            } catch {
                print("Error: \(error)")
            }
        default:
            print("Audio Session Interruption Notification case default")
        }
    }
    
    public func setInitialVolume() {
        guard let session = session else { return }
        initialVolume = CGFloat(session.outputVolume)
        
        if initialVolume > VolumeButtonsHandler.maxVolume {
            initialVolume = VolumeButtonsHandler.maxVolume
            setSystemVolume(initialVolume)
        } else if initialVolume < VolumeButtonsHandler.minVolume {
            initialVolume = VolumeButtonsHandler.minVolume
            setSystemVolume(initialVolume)
        }
        currentVolume = Float(initialVolume)
    }
    
    @objc func applicationDidChangeActive(notification: NSNotification) {
        self.appIsActive = notification.name.rawValue == UIApplication.didBecomeActiveNotification.rawValue
        
        if appIsActive, isStarted {
            // NOTE: There is no guarantee that a begin interruption will have an end interruption
            // so, when the app returns from the background to foreground the audioSessionInterruped method might not be invoked
            // The below is a workaround to restart the session
            if let session = self.session {
                let isPlaying = session.isOtherAudioPlaying
                if !isPlaying {
                    do {
                        try session.setActive(true)
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            setInitialVolume()
        }
    }
    
    public static func volumeButtonHandler(handlerBlock: VolumeButtonBlock?) -> VolumeButtonsHandler {
        let instance = VolumeButtonsHandler()
        instance.handlerBlock = handlerBlock
        return instance
    }
    
    func setSystemVolume(_ volume: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let volumeView = self.volumeView, let volumeSlider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
                self.isAdjustingVolume = true
                volumeSlider.value = Float(volume)
            }
        }
    }

}
