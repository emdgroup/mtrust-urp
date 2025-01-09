import 'package:flutter/foundation.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Abstract wrapper for the core commands, these commands need to be wrapped
/// in a device specific Command Wrapper before they can be send to a device.
abstract class CmdWrapper extends ChangeNotifier {

  /// Ping the device.
  Future<void> ping();

  /// Get the device info.
  Future<UrpDeviceInfo> info();

  /// Get the power state of the device.
  Future<UrpPowerState> getPower();

  /// Set the device name.
  Future<void> setName(String? name);

  /// Get the device name.
  Future<UrpDeviceName> getName();

  /// Pair a device.
  Future<void> pair();

  /// Unpair a device.
  Future<void> unpair();

  /// Start an access point for the firmware update.
  Future<UrpWifiState> startAP(String ssid, String apk);

  /// Stop the access point.
  Future<void> stopAP();

  /// Connect to an access point.
  Future<UrpWifiState> connectAP(String ssid, String apk);

  /// Disconnect from an access point.
  Future<void> disconnectAP();

  /// Start DFU.
  Future<void> startDFU();

  /// Stop DFU.
  Future<void> stopDFU();

  /// Put the device to sleep mode. 
  /// It will disconnect from the device.
  Future<void> sleep();

  /// Turn the device off. It will disconnect from the device.
  Future<void> off();

  /// Reboot the device. It will disconnect from the device.
  Future<void> reboot();

  /// Prevent the device from going to sleep mode.
  Future<void> stayAwake();

  /// Get the public key of the device. 
  Future<UrpPublicKey> getPublicKey();

  /// Get the device id
  Future<UrpDeviceId> getDeviceId();

  /// Identify a reader. Triggers the LED to identify the device.
  Future<void> identify();
}
