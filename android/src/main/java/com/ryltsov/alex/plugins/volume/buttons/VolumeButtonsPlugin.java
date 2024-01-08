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

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void watchVolume(final PluginCall call) {

        call.setKeepAlive(true);
        savedCall = call;

        getBridge()
                .getWebView()
                .setOnKeyListener(
                        new View.OnKeyListener() {
                            @Override
                            public boolean onKey(View v, int keyCode, android.view.KeyEvent event) {
                                boolean isKeyUp = event.getAction() == KeyEvent.ACTION_UP;
                                JSObject ret = new JSObject();

                                if (isKeyUp) {
                                    if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
                                        ret.put("direction", "up");
                                        call.resolve(ret);
                                        return true;
                                    } else if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                                        ret.put("direction", "down");
                                        call.resolve(ret);
                                        return true;
                                    }
                                }

                                return false;
                            }
                        }
                );
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void clearWatch(final PluginCall call) {

        getBridge()
                .getWebView()
                .setOnKeyListener(null);

        getBridge().releaseCall(savedCall);
        savedCall = null;

        call.resolve();
    }
}

