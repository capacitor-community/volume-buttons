//
//  VolumeButtonsPlugin.swift
//
//  Created by Alex Ryltsov on 12/26/23.
//

import Foundation
import Capacitor
import MediaPlayer

@objc(VolumeButtonsPlugin)
public class VolumeButtonsPlugin: CAPPlugin {
    
    private var savedCallID: String? = nil
    private var volumeHandler: VolumeButtonsHandler!
    
    public override func load() {
        volumeHandler = VolumeButtonsHandler()
    }
    
    @objc func isWatching(_ call: CAPPluginCall) {
        
        guard volumeHandler != nil else {
            call.reject("Volume handler has not been initialized yet")
            return
        }
        
        call.resolve([
            "value": volumeHandler.isStarted
        ])
    }

    @objc func watchVolume(_ call: CAPPluginCall) {
        
        guard !volumeHandler.isStarted else {
            call.reject("Volume buttons has already been watched")
            return
        }
        
        let disableSystemVolumeHandler = call.getBool("disableSystemVolumeHandler", false)
        
        call.keepAlive = true
        savedCallID = call.callbackId
        
        volumeHandler.startHandler(disableSystemVolumeHandler)
        
        let handlerBlock: VolumeButtonBlock = { direction in
            if let id = self.savedCallID, let savedCall = self.bridge?.savedCall(withID: id) {
                var jsObject = JSObject()
                jsObject["direction"] = direction
                savedCall.resolve(jsObject)
            }
        }
        volumeHandler.handlerBlock = handlerBlock
        
    }
    
    @objc func clearWatch(_ call: CAPPluginCall) {

        guard volumeHandler.isStarted else {
            call.reject("Volume buttons has not been been watched")
            return
        }
        
        if let id = savedCallID {
            volumeHandler.stopHandler()
            if let savedCall = bridge?.savedCall(withID: id) {
                bridge?.releaseCall(savedCall)
            }
            savedCallID = nil
            call.resolve()
        }

    }
    
}
