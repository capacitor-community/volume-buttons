import { Component } from '@angular/core';
import {
  IonHeader, IonButton, IonToolbar, IonTitle, IonContent, IonCard, IonCardContent
} from '@ionic/angular/standalone';

import { Subscription } from 'rxjs';
import { throttleTime } from 'rxjs/operators';

// PROVIDERS
import { VolumeButtonsUtils } from '../services/utils/volume-buttons-utils';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
  imports: [
    IonButton, IonHeader, IonToolbar, IonTitle, IonContent, IonCard, IonCardContent
  ]
})
export class HomePage {

  private volumeUpButtonsEventsSub: Subscription | null = null;

  constructor(
    private volumeButtonsUtils: VolumeButtonsUtils
  ) { }

  public async watchVolumeButtonsPressed(): Promise<void> {
    this.volumeUpButtonsEventsSub = this.volumeButtonsUtils.volumeUpButtonEvents
      .pipe(
        throttleTime(500)
      )
      .subscribe(() => {
        const currentTimeFormatted = new Date().toLocaleTimeString();
        alert(`Volume Button Pressed: ${currentTimeFormatted}`);
      });

    try {
      await this.volumeButtonsUtils.watchVolumeUpButton();
    } catch (error) {
      console.error('[HomePage] watchVolumeButtonsPressed - failed to set up volume buttons watch', error);
    }
  }
  public async unwatchVolumeButtonsPressed(): Promise<void> {

    try {
      await this.volumeButtonsUtils.clearWatch();
    } catch (error) {
      console.error('[HomePage] unwatchVolumeButtonsPressed - failed to clear watch for the volume buttons', error);
    }

    if (this.volumeUpButtonsEventsSub?.closed === false) {
      this.volumeUpButtonsEventsSub.unsubscribe();
      this.volumeUpButtonsEventsSub = null;
    }

  }
  public async isVolumeButtonsWatched(): Promise<void> {

    try {
      const isVolumeUpButtonsWatched = await this.volumeButtonsUtils.isVolumeUpButtonsWatched();
      alert(`isVolumeUpButtonsWatched: ${isVolumeUpButtonsWatched}`);
    } catch (error) {
      console.error('[HomePage] isVolumeButtonsWatched - failed to check if the hardware volume buttons are watched', error);
    }

  }

}
