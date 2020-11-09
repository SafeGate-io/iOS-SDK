# SafeGate iOS SDK

[![Version](https://img.shields.io/cocoapods/v/SafeGateSDK.svg?style=flat)](https://cocoapods.org/pods/SafeGateSDK)
[![License](https://img.shields.io/cocoapods/l/SafeGateSDK.svg?style=flat)](https://cocoapods.org/pods/SafeGateSDK)
[![Platform](https://img.shields.io/cocoapods/p/SafeGateSDK.svg?style=flat)](https://cocoapods.org/pods/SafeGateSDK)

* [Requirements](#requirements)
* [Installation](#installation)
  + [CocoaPods](#cocoapods)
* [Usage](#usage)
* [Debugging](#debugging)
* [License](#license)

## Requirements

- iOS 12.0+
- Xcode 11.0+

## Installation

### CocoaPods

1. Create a Podfile if you don't have one: `pod init`
2. Add Adapty to your Podfile: `pod 'SafeGateSDK', '~> 1.0.0'`
3. Save the file and run: `pod install`. This creates an `.xcworkspace` file for your app. Use this file for all future development on your application.

## Usage

In your file:

```Swift
import SafeGateSDK
```

## Debugging

SafeGateSDK will log errors and other important information to help you understand what is going on. There are three levels available: **`verbose`**, **`errors`** and **`none`** in case you want a bit of a silence.
You can set this at any moment in your app.

```Swift
SafeGateSDK.logLevel = .verbose
```

## License

SafeGateSDK is available under the Apache license. [See LICENSE](https://github.com/SafeGate-io/iOS-SDK/blob/main/LICENSE) for details.
