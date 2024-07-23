/*
 * @capacitor-community/volume-buttons plugin
 *
 * This software contains code derived from or inspired by the following sources:
 *
 * 1. Original code from the CapacitorVolumeButtonsPlugin.java
 *    - Original code URL: https://github.com/thiagobrez/capacitor-volume-buttons
 *    - Original code authors: Thiago Brezinski
 *
 * 2. Modifications made by Alex Ryltsov to the original code:
 *    - changed to use watchVolume/clearWatch plugin methods instead of the load method to setup/tear down the hardware volume buttons events listener
 *
 */


package com.ryltsov.alex.plugins.volume.buttons;

import android.view.KeyEvent;
import android.view.View;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "VolumeButtons")
public class VolumeButtonsPlugin extends Plugin {

    private PluginCall savedCall;
    private boolean isStarted = false;

    private boolean suppressVolumeIndicator = false;

    @PluginMethod(returnType = PluginMethod.RETURN_PROMISE)
    public void isWatching(final PluginCall call) {

        JSObject ret = new JSObject();
        ret.put("value", isStarted);
        call.resolve(ret);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void watchVolume(final PluginCall call) {

        if (isStarted) {
            call.reject("Volume buttons has already been watched");
            return;
        }

        suppressVolumeIndicator = Boolean.TRUE.equals(call.getBoolean("suppressVolumeIndicator", true));

        call.setKeepAlive(true);
        savedCall = call;

        getBridge()
                .getWebView()
                .setOnKeyListener(
                        new View.OnKeyListener() {
                            @Override
                            public boolean onKey(View v, int keyCode, android.view.KeyEvent event) {
                                if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                                    boolean isKeyUp = event.getAction() == KeyEvent.ACTION_UP;
                                    if (isKeyUp) {
                                        JSObject ret = new JSObject();
                                        ret.put("direction", keyCode == KeyEvent.KEYCODE_VOLUME_UP ? "up" : "down");
                                        call.resolve(ret);
                                    }
                                    // NOTE: we return suppressVolumeIndicator value for volume buttons event actions only
                                    // therefore, when suppressVolumeIndicator is true, for a key event that typically controls the system volume,
                                    // the system volume indicator will not be displayed by default.
                                    // This is because returning true from onKey() indicates that your application has consumed
                                    // the key event and no system-level action should occur in response to that event.
                                    return suppressVolumeIndicator;
                                }

                                return false;
                            }
                        }
                );

        isStarted = true;
    }

    @PluginMethod(returnType = PluginMethod.RETURN_PROMISE)
    public void clearWatch(final PluginCall call) {

        if (!isStarted) {
            call.reject("Volume buttons has not been been watched");
            return;
        }

        getBridge()
                .getWebView()
                .setOnKeyListener(null);

        getBridge().releaseCall(savedCall);
        savedCall = null;

        isStarted = false;

        call.resolve();

    }
}

