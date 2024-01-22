//
//  VolumeButtonsPlugin.m
//
//  Created by Alex Ryltsov on 12/26/23.
//

#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(VolumeButtonsPlugin, "VolumeButtons",
    CAP_PLUGIN_METHOD(isWatching, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(watchVolume, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(clearWatch, CAPPluginReturnPromise);
)
