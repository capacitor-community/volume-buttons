export type CallbackID = string;

export interface VolumeButtonsOptions {
  /**
   * This parameter can be used to disable the system volume handler (iOS only).
   * If this is true, when up or down volume button is tapped, the system volume will always be reset to either
   * the initial volume (the volume which was current when the volume buttons are started to be tracked/listened)
   * or to 0.05 if the initial volume is less then 0.05 or to 0.95 if the initial volume
   * is greater then 0.95.
   *
   * @since 1.0.0
   */
  disableSystemVolumeHandler?: boolean;
}

export type VolumeButtonsCallback = (
  result: VolumeButtonsResult,
  err?: any,
) => void;

export interface VolumeButtonsResult {
  /**
   * This indicates either the volume up or volume down button was pressed.
   *
   * @since 1.0.0
   */
  direction: 'up' | 'down';
}

export interface VolumeButtonsPlugin {

  /**
   * Set up a watch for he hardware volume buttons changes
   *
   * @since 1.0.0
   */
  watchVolume(options: VolumeButtonsOptions, callback: VolumeButtonsCallback): Promise<CallbackID>;

  /**
   * Clear the existing watch
   *
   * @since 1.0.0
   */
  clearWatch(): Promise<void>;

}
