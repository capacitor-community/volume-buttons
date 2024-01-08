import { WebPlugin } from '@capacitor/core';

import type { CallbackID, VolumeButtonsOptions, VolumeButtonsPlugin, VolumeButtonsCallback } from './definitions';

export class VolumeButtonsWeb
  extends WebPlugin
  implements VolumeButtonsPlugin {

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  public async watchVolume(_options: VolumeButtonsOptions, _callback: VolumeButtonsCallback): Promise<CallbackID> {
    throw new Error('VolumeButtons is not supported on web');
  }

  public async clearWatch(): Promise<void> {
    throw new Error('VolumeButtons is not supported on web');
  }

}
