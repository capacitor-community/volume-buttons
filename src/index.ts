import { registerPlugin } from '@capacitor/core';

import type { VolumeButtonsPlugin } from './definitions';

const VolumeButtons = registerPlugin<VolumeButtonsPlugin>('VolumeButtons', {
  web: () => import('./web').then((m) => new m.VolumeButtonsWeb()),
});

export * from './definitions';
export { VolumeButtons };
