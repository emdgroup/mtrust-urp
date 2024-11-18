# M-Trust SDKs: Integrating with our Hardware Devices
<img src="https://github.com/emdgroup/mtrust-urp/blob/main/banner.png?raw=true" width="300"/>


[![Documentation Status](https://img.shields.io/badge/Documentation-M--Trust%20SDKs-blue?style=flat&logo=readthedocs)](https://docs.mtrust.io/sdks)

The M-Trust SDKs allow you to integrate our hardware tightly within your mobile applications. The SDKs are available for the SEC-Reader, IMP-Reader.

The SDKs allow you to quickly integrate an identification and verification step into your application.

<details>
    <summary>All pub.dev packages included in the repository.</summary>

#### mtrust_urp_core
[![pub package](https://img.shields.io/pub/v/mtrust_urp_core.svg)](https://pub.dev/packages/mtrust_urp_core)
[![pub points](https://img.shields.io/pub/points/mtrust_urp_core)](https://pub.dev/packages/mtrust_urp_core/score)

#### mtrust_urp_ui
[![pub package](https://img.shields.io/pub/v/mtrust_urp_ui.svg)](https://pub.dev/packages/mtrust_urp_ui)
[![pub points](https://img.shields.io/pub/points/mtrust_urp_ui)](https://pub.dev/packages/mtrust_urp_ui/score)
#### mtrust_urp_ble_strategy
[![pub package](https://img.shields.io/pub/v/mtrust_urp_ble_strategy.svg)](https://pub.dev/packages/mtrust_urp_ble_strategy)
[![pub points](https://img.shields.io/pub/points/mtrust_urp_ble_strategy)](https://pub.dev/packages/mtrust_urp_ble_strategy/score)
#### mtrust_urp_virtual_strategy
[![pub package](https://img.shields.io/pub/v/mtrust_urp_virtual_strategy.svg)](https://pub.dev/packages/mtrust_urp_virtual_strategy)
[![pub points](https://img.shields.io/pub/points/mtrust_urp_virtual_strategy)](https://pub.dev/packages/mtrust_urp_virtual_strategy/score)

</details>


### Cross-Platform Compatibility

The SDKs are optimized for cross-platform mobile development, with support for iOS and Android devices. Built using the [Flutter](https://flutter.dev/) framework, they provide a unified development experience across platforms, simplifying app development and maintenance.

While we recommend to implement your application using Flutter, the SDKs can also be used in native iOS and Android applications by following the [native embedding guides](https://docs.flutter.dev/add-to-app) provided by Flutter.
Depending on the connection strategies you want to enable please make sure to configure the correct permissions:

| <img src="https://github.com/emdgroup/mtrust-sec-kit/blob/main/banner.png?raw=true" width="200">                                                                                                                                | <img src="https://github.com/emdgroup/mtrust-imp-kit/blob/main/banner.png?raw=true" width="200">                                                                                                                                | <img src="https://github.com/emdgroup/mtrust-barcode-kit/blob/main/banner.png?raw=true" width="200">                                                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **SEC Kit**                                                                                                                                                                                                                     | **IMP Kit**                                                                                                                                                                                                                     | **Barcode Kit**                                                                                                                                                                                                                                 |
| Integrate with</br>SEC-Readers                                                                                                                                                                                                  | Integrate with</br>IMP-Readers                                                                                                                                                                                                  | Read barcodes on</br> iOS and Android                                                                                                                                                                                                           |
| [![pub package](https://img.shields.io/pub/v/mtrust_sec_kit.svg)](https://pub.dev/packages/mtrust_sec_kit)</br>[![pub points](https://img.shields.io/pub/points/mtrust_sec_kit)](https://pub.dev/packages/mtrust_sec_kit/score) | [![pub package](https://img.shields.io/pub/v/mtrust_imp_kit.svg)](https://pub.dev/packages/mtrust_imp_kit)</br>[![pub points](https://img.shields.io/pub/points/mtrust_imp_kit)](https://pub.dev/packages/mtrust_imp_kit/score) | [![pub package](https://img.shields.io/pub/v/mtrust_barcode_kit.svg)](https://pub.dev/packages/mtrust_barcode_kit)</br>[![pub points](https://img.shields.io/pub/points/mtrust_barcode_kit)](https://pub.dev/packages/mtrust_barcode_kit/score) |


# Installation

## Android

In `android/app/src/main/AndroidManifest.xml`, add the following permissions:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <application>
    ...
</manifest>
```

## iOS

In `ios/Runner/Info.plist`, add the following keys for Bluetooth and location permissions:

```xml
    <dict>
        ...
	    <key>NSBluetoothAlwaysUsageDescription</key>
	    <string>Need BLE permission</string>
	    <key>NSBluetoothPeripheralUsageDescription</key>
	    <string>Need BLE permission</string>
	    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	    <string>Need Location permission</string>
	    <key>NSLocationAlwaysUsageDescription</key>
	    <string>Need Location permission</string>
	    <key>NSLocationWhenInUseUsageDescription</key>
	    <string>Need Location permission</string>
```

## USB Serial
### MacOS
In `macos/Runner/[DebugProfile/Release].entitlements`, add:

```xml
<dict>
    ...
    <key>com.apple.security.device.serial</key>
    <true/>
</dict>
```

### Android
In `android/app/src/main/AndroidManifest.xml`, add the following for USB host support:

```xml
    <manifest ...>
    <uses-feature android:name="android.hardware.usb.host"
                  android:required="true"/>

    <application>
        <activity>
            ...
            <intent-filter>
                <action android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" />
            </intent-filter>
            <meta-data android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" android:resource="@xml/device_filter" />
        </activity>
    </application>

```

Add a file at `android/app/src/main/res/xml/device_filter.xml` with the following content:

```xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <usb-device vendor-id="1155" product-id="22336" />
    </resources>
```

## Contributing
We welcome contributions! Please fork the repository and submit a pull request with your changes. Ensure that your code adheres to our coding standards and includes appropriate tests.

## License
This project is licensed under the Apache 2.0 License. See the [LICENSE](./LICENSE) file for details.