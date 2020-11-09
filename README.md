
# SafeGate iOS SDK

The SafeGate iOS SDK, for integrating SafeGate device into your iOS application.
  Including:
    - Face, Glasses, Masks, Distance Detection
    - SafeGate Thermal Camera Connection
    - SafeGate Thermal Camera Measurement

[![Version](https://img.shields.io/cocoapods/v/SafeGateSDK.svg?style=flat)](https://cocoapods.org/pods/SafeGateSDK)
[![License](https://img.shields.io/cocoapods/l/SafeGateSDK.svg?style=flat)](https://cocoapods.org/pods/SafeGateSDK)
[![Platform](https://img.shields.io/cocoapods/p/SafeGateSDK.svg?style=flat)](https://cocoapods.org/pods/SafeGateSDK)

* [Requirements](#requirements)
* [Installation](#installation)
  + [CocoaPods](#cocoapods)
* [Update Info.plist](#update-info.plist)
  + [Bluetooth Usage](#bluetooth-usage)
* [Usage](#usage)
  + [Connection](#connection)
  + [Measurement](#measurement)
  + [Detections](#detections)
  + [HeatMap](#heatmap)
<!-- * [Example App](#example-app) -->
<!-- * [Debugging](#debugging) -->
+ [Apple Silicon Support](#apple-silicon-support)
* [License](#license)

## Requirements

- iOS 12.0+
- Xcode 11.0+

## Installation

### CocoaPods

1. Create a Podfile if you don't have one: `pod init`
2. Add SafeGateSDK to your Podfile: `pod 'SafeGateSDK', '~> 1.0.0'`
3. Save the file and run: `pod install`. This creates an `.xcworkspace` file for your app. Use this file for all future development on your application.

## Update Info.plist

#### Bluetooth Usage:

SDK uses **Bluetooth** to estabilish connection with Thermal Camera. When installing **SafeGateSDK**, you'll need to make sure that you have a `NSBluetoothAlwaysUsageDescription` and `NSBluetoothPeripheralUsageDescription` entries in your `Info.plist`.


## Usage

SDK works with this main classes:
- `ThermalCamera` - camera instance class with `id`, `name`, `isConnected` state and `peripheral` - CoreBluetooth peripheral class.
- `TemperatureMeter` - helps to connect, to listen connection state of `ThermalCamera`, measure and work with `Temperatures` received from camera.
- `Temperature`/`Temperatures` - type aliases of `Measurement<UnitTemperature>` and `[[Temperature]]`
- `HeatMapDrawer` - draws `HeatMap` image from temperatures data with setted `Pallete`.
- `Detection` - helps to detect `Face` from *VideoImageBuffer*, to detect `Mask`, `Glasses` at face, to detect `Distance` to face.

In your file:

```Swift
import SafeGateSDK
```

### Connection

Create `TemperatureMeter` instance by default init:
```Swift
 let temperatureMeter = TemperatureMeter()
 ```

Available 3 connection options for thermal camera:

 1. Connect with thermal camera by `id`:
```Swift
func estabilishConnectionWithCamera(id: UUID, timeout: Int, completion: @escaping Completion<ThermalCamera>)
```

<details>
  <summary>Example</summary>

```Swift
 temperatureMeter.estabilishConnectionWithCamera(id: cameraId, timeout: 10) { result in
    switch result {
    case .success(let camera):
       print(camera.id)
    case .failure(ler error):
       print(error)
    }
}
  ```
</details>

 2. Connect with `first found` camera:
```Swift
func estabilishConnectionWithFirstThermalCamera(timeout: Int, completion: @escaping Completion<ThermalCamera>)
```

<details>
  <summary>Example</summary>

```Swift
 temperatureMeter.estabilishConnectionWithFirstThermalCamera(timeout: 10) { result in
    switch result {
    case .success(let camera):
       print(camera.id)
    case .failure(ler error):
       print(error)
    }
}
  ```
</details>

 3. Restore connection with `already saved` camera:
```Swift
func connect(to camera: ThermalCamera, completion: @escaping Completion<ThermalCamera>)
```

<details>
  <summary>Example</summary>

```Swift
 temperatureMeter.connect(to: savedCamera) { result in
    switch result {
    case .success(let camera):
       print(camera.id)
    case .failure(ler error):
       print(error)
    }
}
  ```
</details>

Completion of each func returns result with connected `ThermalCamera` or `Error` if connection failed.

### Measurement

Create `TemperatureMeter` instance by default init:
```Swift
 let temperatureMeter = TemperatureMeter()
 ```

Before measurement you **must connect** to thermal camera.
All functions with measurement at SDK returns in **deciKelvin**(`Kelvin * 10^-1`)
Measure temperature from the camera:
```Swift
func measure(completion: @escaping Completion<Temperatures>)
```

<details>
  <summary>Example</summary>

```Swift
 temperatureMeter.measure { result in
    switch result {
    case .success(let temperatures):
       print(temperatures)
    case .failure(ler error):
       print(error)
    }
}
  ```
</details>

Completion returns `Temperatures` or `Error` if measurement failed. Temperatures is 2d array, it's representing **32x32** pixels image with temperatures. Each item of array or pixel of image is `deciKelvin` temperature.

### HeatMap
HeatMap drawing documentation will be added later.

### Detections

Create `Detection` instance by default init:
```Swift
 let detectionManager = Detection()
 ```

Detect **Face** from [Video Image Buffer](https://developer.apple.com/documentation/coremedia/cmsamplebuffer-u71):
```Swift
func detectFace(at buffer: CMSampleBuffer, metadata: Metadata, completion: @escaping Completion<Face?>)
```

<details>
  <summary>Example</summary>

```Swift
 detectionManager.detectFace(at: imageBuffer, metadata: metadata) { result in
    switch result {
    case .success(let face):
	    if let face = face {
            print(face)
	    } else {
		    print("not found face")
	    }
    case .failure(ler error):
        print(error)
    }
}
  ```
</details>

Detect **Mask**, **Glasses** on face, **Distance** to face:
```Swift
func detectGlasses(at face: Face, classifier: Classifier.Type?, confidence: Float, completion: @escaping Completion<Glasses>)
```
```Swift
func detectMask(at face: Face, classifier: Classifier.Type?, confidence: Float, completion: @escaping Completion<Mask>)
```
```Swift
func detectDistance(to face: Detection.Face, normalRange range: ClosedRange<Distance.Value>, completion: @escaping Completion<Distance>)
```

<!--## Example app
There are example apps provided [here](https://github.com/safegate-io/ios-sdk/tree/master/Examples) for Swift.
-->

<!-- ## Debugging

SafeGateSDK will log errors and other important information to help you understand what is going on. There are three levels available: **`verbose`**, **`errors`** and **`none`** in case you want a bit of a silence.
You can set this at any moment in your app.

```Swift
SafeGateSDK.logLevel = .verbose
``` -->

## Apple Silicon Support
The SafeGate iOS SDK does not support Apple Silicon `arm64` architecture.
For Cocoapods integrations, we have explicitly excluded `arm64` architecture from simulator builds to prevent build failures. We do this by modifying app and pod build settings via the Intercom podspec.
We hope to be able to remove these build setting requirements and provide support for Apple Silicon in the near future when we distribute the iOS SDK as an XCFramework binary.


## License

SafeGateSDK is available under the Apache license. [See LICENSE](https://github.com/SafeGate-io/iOS-SDK/blob/main/LICENSE) for details.
