<p align="center"><br><img src="https://user-images.githubusercontent.com/236501/85893648-1c92e880-b7a8-11ea-926d-95355b8175c7.png" width="128" height="128" /></p>
<h3 align="center">Capacitor Volume Buttons Plugin</h3>
<p align="center"><strong><code>@capacitor-community/volume-buttons</code></strong></p>
<p align="center">
  Capacitor community plugin to listen to hardware volume button presses
</p>

<p align="center">
  <img src="https://img.shields.io/maintenance/yes/2024?style=flat-square" />
  <a href="https://www.npmjs.com/package/@capacitor-community/volume-buttons"><img src="https://img.shields.io/npm/l/@capacitor-community/volume-buttons?style=flat-square" /></a>
  <br>
  <a href="https://www.npmjs.com/package/@capacitor-community/volume-buttons"><img src="https://img.shields.io/npm/dw/@capacitor-community/volume-buttons?style=flat-square" /></a>
  <a href="https://www.npmjs.com/package/@capacitor-community/volume-buttons"><img src="https://img.shields.io/npm/v/@capacitor-community/volume-buttons?style=flat-square" /></a>
  <!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
  <a href="#contributors-"><img src="https://img.shields.io/badge/all%20contributors-1-orange?style=flat-square" /></a>
  <!-- ALL-CONTRIBUTORS-BADGE:END -->
</p>

## Table of Contents

- [Maintainers](#maintainers)
- [About](#about)
- [Plugin versions](#plugin-versions)
- [Supported Platforms](#supported-platforms)
- [Installation](#installation)
- [API](#api)
- [Troubleshooting](#troubleshooting)

## Maintainers

| Maintainer | GitHub                          | Active |
| ---------- | ------------------------------- | ------ |
| ryaa       | [ryaa](https://github.com/ryaa) | yes    |

## About

This plugins allows to listen for the events fired when the user presses the hardware volume up or down button of the device. An object that contains only one property is passed to the callback - see [VolumeButtonsResult](#VolumeButtonsResult).
This plugin contains code derived from or inspired by https://github.com/CipherBitCorp/VolumeButtonHandler and https://github.com/thiagobrez/capacitor-volume-buttons plugins.

<br>

**Features:**

- support receiving events when the volume is max or min (make sure to use **`disableSystemVolumeHandler`** on iOS platform - see [VolumeButtonsOptions](#VolumeButtonsOptions))
- keep receiving events after the application sent to and returns from the background
- supports Android and iOS platforms

**NOTE**: The plugin version 7.0.0 is compatible with Capacitor 7

## Plugin versions

| Capacitor version | Plugin version |
| ----------------- | -------------- |
| 7.x               | 7.x            |
| 6.x               | 6.x            |
| 5.x               | 1.x            |

## Supported Platforms

- iOS
- Android

## Installation

```bash
npm install @capacitor-community/volume-buttons
npx cap sync
```

## API

<docgen-index>

* [`isWatching()`](#iswatching)
* [`watchVolume(...)`](#watchvolume)
* [`clearWatch()`](#clearwatch)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### isWatching()

```typescript
isWatching() => Promise<GetIsWatchingResult>
```

Get the watch status of the volume buttons.

**Returns:** <code>Promise&lt;<a href="#getiswatchingresult">GetIsWatchingResult</a>&gt;</code>

**Since:** 1.0.1

--------------------


### watchVolume(...)

```typescript
watchVolume(options: VolumeButtonsOptions, callback: VolumeButtonsCallback) => Promise<CallbackID>
```

Set up a watch for he hardware volume buttons changes

| Param          | Type                                                                    |
| -------------- | ----------------------------------------------------------------------- |
| **`options`**  | <code><a href="#volumebuttonsoptions">VolumeButtonsOptions</a></code>   |
| **`callback`** | <code><a href="#volumebuttonscallback">VolumeButtonsCallback</a></code> |

**Returns:** <code>Promise&lt;string&gt;</code>

**Since:** 1.0.0

--------------------


### clearWatch()

```typescript
clearWatch() => Promise<void>
```

Clear the existing watch

**Since:** 1.0.0

--------------------


### Interfaces


#### GetIsWatchingResult

| Prop        | Type                 | Description                              | Since |
| ----------- | -------------------- | ---------------------------------------- | ----- |
| **`value`** | <code>boolean</code> | If the volume buttons are being watched. | 1.0.1 |


#### VolumeButtonsOptions

| Prop                             | Type                 | Description                                                                                                                                                                                                                                                                                                                                                                                                   | Since |
| -------------------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **`disableSystemVolumeHandler`** | <code>boolean</code> | This parameter can be used to disable the system volume handler (iOS only). If this is true, when up or down volume button is tapped, the system volume will always be reset to either the initial volume (the volume which was current when the volume buttons are started to be tracked/listened) or to 0.05 if the initial volume is less then 0.05 or to 0.95 if the initial volume is greater then 0.95. | 1.0.0 |
| **`suppressVolumeIndicator`**    | <code>boolean</code> | This parameter can be used to suppress/hide the system volume indicator (Android only, it is never shown on iOS already). If this is true, when up or down volume button is tapped, the system volume indicator will not be shown. The default value is false.                                                                                                                                                | 1.0.2 |


#### VolumeButtonsResult

| Prop            | Type                        | Description                                                            | Since |
| --------------- | --------------------------- | ---------------------------------------------------------------------- | ----- |
| **`direction`** | <code>'up' \| 'down'</code> | This indicates either the volume up or volume down button was pressed. | 1.0.0 |


### Type Aliases


#### VolumeButtonsCallback

<code>(result: <a href="#volumebuttonsresult">VolumeButtonsResult</a>, err?: any): void</code>


#### CallbackID

<code>string</code>

</docgen-api>

## Usage

Please also see **example-app** for a complete example.

### Add volume button listener in the app

```
import { VolumeButtons } from '@capacitor-community/volume-buttons';

const options: VolumeButtonsOptions = {};
const callback: VolumeButtonsCallback = (result: VolumeButtonsResult, err?: any) => {
  console.log('result', result);
};
if (this.platform.is('ios')) {
  options.disableSystemVolumeHandler = true;
} else if (this.platform.is('android')) {
  options.suppressVolumeIndicator = true;
}
await VolumeButtons.watchVolume(options, callback);
```

### Remove volume button listener in the app

```
import { VolumeButtons } from '@capacitor-community/volume-buttons';

await VolumeButtons.clearWatch();
```
