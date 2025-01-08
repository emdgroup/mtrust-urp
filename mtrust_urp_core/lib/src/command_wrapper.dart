import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_core/src/api_service.dart';

/// Wrapper for the commands
class CmdWrapper extends ChangeNotifier {
  /// Creates a new instance of [CmdWrapper]
  CmdWrapper({
    required this.strategy,
    required this.target,
    required this.origin,
  }) {
    strategy.onPing(ping);
  }

  /// The connection strategy
  ConnectionStrategy strategy;

  /// The target device
  UrpDeviceIdentifier target;

  /// The origin device
  UrpDeviceIdentifier origin;

  /// Pings the device.
  Future<void> ping() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpPing,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Info returns the device info.
  Future<UrpDeviceInfo> info() async {
    final res = await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpGetInfo,
      ).writeToBuffer(),
      target,
      origin,
    );

    if (!res.hasPayload()) {
      throw Exception('Failed to get info');
    }
    return UrpDeviceInfo.fromBuffer(res.payload);
  }

  /// Returns the power state of the device.
  Future<UrpPowerState> getPower() async {
    final res = await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpGetPower,
      ).writeToBuffer(),
      target,
      origin,
    );

    if (!res.hasPayload()) {
      throw Exception('Failed to get power state');
    }
    return UrpPowerState.fromBuffer(res.payload);
  }

  /// Sets the device name.
  Future<void> setName(String name) async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpSetName,
        setNameParameters: UrpSetNameParameters(name: name),
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Gets the device name. Returns the result if successful.
  /// Triggers an error if failed.
  Future<UrpDeviceName> getName() async {
    final res = await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpGetName,
      ).writeToBuffer(),
      target,
      origin,
    );

    if (!res.hasPayload()) {
      throw Exception('Failed to get name');
    }
    return UrpDeviceName.fromBuffer(res.payload);
  }

  /// Pair a device.
  Future<void> pair() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpPair,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Unpair a device.
  Future<void> unpair() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpUnpair,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Start an access point for the firmware update.
  Future<UrpWifiState> startAP(String ssid, String apk) async {
    final res = await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpStartAp,
        apParameters: UrpApParamters(ssid: ssid, password: apk),
      ).writeToBuffer(),
      target,
      origin,
    );
    return UrpWifiState.fromBuffer(res.payload);
  }

  /// Stops the access point.
  Future<void> stopAP() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpStopAp,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Connects to an access point.
  Future<UrpWifiState> connectAP(String ssid, String apk) async {
    final res = await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpConnectAp,
        apParameters: UrpApParamters(ssid: ssid, password: apk),
      ).writeToBuffer(),
      target,
      origin,
    );
    return UrpWifiState.fromBuffer(res.payload);
  }

  /// Disconnects from an access point.
  Future<void> disconnectAP() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpDisconnectAp,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Starts DFU.
  Future<void> startDFU() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpStartDfu,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Stops DFU.
  Future<void> stopDFU() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpStopDfu,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Sleep put the device to sleep mode. It will disconnect from the device.
  Future<void> sleep() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpSleep,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Turns the device off. It will disconnect from the device.
  Future<void> off() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpOff,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Reboots the device. It will disconnect from the device.
  Future<void> reboot() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpReboot,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Prevents the device from going to sleep mode.
  Future<void> stayAwake() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpStayAwake,
      ).writeToBuffer(),
      target,
      origin,
    );
  }

  /// Gets the public key of the device. Returns the result if successful.
  /// Triggers an error if failed.
  Future<UrpPublicKey> getPublicKey() async {
    final res = await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpGetPublicKey,
      ).writeToBuffer(),
      target,
      origin,
    );

    if (!res.hasPayload()) {
      throw Exception('Failed to get public key');
    }
    return UrpPublicKey.fromBuffer(res.payload);
  }

  /// Gets the device id. Returns the result if successful.
  /// Triggers an error if failed.
  Future<UrpDeviceId> getDeviceId() async {
    final res = await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpGetDeviceId,
      ).writeToBuffer(),
      target,
      origin,
    );

    if (!res.hasPayload()) {
      throw Exception('Failed to get device id');
    }
    return UrpDeviceId.fromBuffer(res.payload);
  }

  /// Identify reader. Triggers the LED to identify the device.
  Future<void> identify() async {
    await strategy.addQueue(
      UrpCoreCommand(
        command: wrapper.UrpCommand.urpIdentify,
      ).writeToBuffer(),
      target,
      origin,
    );
  }
}
