
- **Permissions**: 
    - **Android**:
    Add the required permissions to your `AndroidManifest.xml` 
    ```xml
    <!-- Tell Google Play Store that your app uses Bluetooth LE
     Set android:required="true" if bluetooth is necessary -->
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />

    <!-- New Bluetooth permissions in Android 12
    https://developer.android.com/about/versions/12/features/bluetooth-permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <!-- legacy for Android 11 or lower -->
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30"/>

    <!-- legacy for Android 9 or lower -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />
    ```
    To avoid errors in release builds, please add the following line into your `project/android/app/proguard-rules.pro` file.
    ```
    -keep class com.lib.flutter_blue_plus.* { *; }
    ``` 

    - **iOS**: Add the required permission to your `ios/Runner/Info.plist` file
    ```plist
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app always needs Bluetooth to function</string>
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth Peripheral to function</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app always needs location and when in use to function</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>This app always needs location to function</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location when in use to function</string>
    ```