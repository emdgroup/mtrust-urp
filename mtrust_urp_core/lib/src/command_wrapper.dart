import 'package:flutter/foundation.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_core/src/api_service.dart';

/// Abstract wrapper for the core commands, these commands need to be wrapped
/// in a device specific Command Wrapper before they can be send to a device.
abstract class CmdWrapper extends ChangeNotifier {
  /// Adds a core command to the queue.
  /// Need to be implemented by the specific device wrapper.
  Future<UrpResponse> addCoreCmdToQueue(UrpCoreCommand command);

  /// Gets the power state of the device.
  Future<UrpPowerState> getPower() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpGetPower,
    );
    final res = await addCoreCmdToQueue(cmd);

    return UrpPowerState.fromBuffer(res.payload);
  }

  /// Pings the device.
  Future<void> ping() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpPing,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Returns the device info. Throws an error if failed.
  Future<UrpDeviceInfo> info() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpGetInfo,
    );
    final res = await addCoreCmdToQueue(cmd);

    return UrpDeviceInfo.fromBuffer(res.payload);
  }

  /// Sets the name of the device.
  Future<void> setName(String? name) async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpSetName,
      setNameParameters: UrpSetNameParameters(name: name),
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Returns the device name. Throws an error if failed.
  Future<UrpDeviceName> getName() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpGetName,
    );
    final res = await addCoreCmdToQueue(cmd);

    return UrpDeviceName.fromBuffer(res.payload);
  }

  /// Unpair the device.
  Future<void> unpair() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpUnpair,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Starts the DFU mode of the device.
  Future<void> startDFU() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpStartDfu,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Start AP. Throws an error if failed.
  Future<UrpWifiState> startAP(String ssid, String apk) async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpStartAp,
      apParameters: UrpApParamters(ssid: ssid, password: apk),
    );
    final res = await addCoreCmdToQueue(cmd);

    return UrpWifiState.fromBuffer(res.payload);
  }

  /// Stop AP.
  Future<void> stopAP() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpStopAp,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Connect AP. Throws an error if failed.
  Future<UrpWifiState> connectAP(String ssid, String apk) async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpConnectAp,
      apParameters: UrpApParamters(ssid: ssid, password: apk),
    );
    final res = await addCoreCmdToQueue(cmd);

    return UrpWifiState.fromBuffer(res.payload);
  }

  /// Disconnect AP.
  Future<void> disconnectAP() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpDisconnectAp,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Stops the DFU mode of the device.
  Future<void> stopDFU() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpStopDfu,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Puts the device to sleep mode. This will disconnect the device.
  Future<void> sleep() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpSleep,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Turns the device off. This will disconnect the device.
  Future<void> off() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpOff,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Reboots the device. This will disconnect the device.
  Future<void> reboot() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpReboot,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Prevents the device from going to sleep mode.
  Future<void> stayAwake() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpStayAwake,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Returns the public key of the device. Throws an error if failed.
  Future<UrpPublicKey> getPublicKey() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpGetPublicKey,
    );
    final res = await addCoreCmdToQueue(cmd);
    return UrpPublicKey.fromBuffer(res.payload);
  }

  /// Return the device id. Throws an error if failed.
  Future<UrpDeviceId> getDeviceId() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpGetDeviceId,
    );
    final res = await addCoreCmdToQueue(cmd);
    return UrpDeviceId.fromBuffer(res.payload);
  }

  /// Identify reader. Triggers the LED to identify the device.
  Future<void> identify() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpIdentify,
    );
    await addCoreCmdToQueue(cmd);
  }

  /// Get the URP types version supported by the device
  Future<UrpTypesVersion> getVersion() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpGetVersion,
    );
    final res = await addCoreCmdToQueue(cmd);
    return UrpTypesVersion.fromBuffer(res.payload);
  }

  /// Fetch new token
  /// TODO: rephrase this to refreshToken or something similar
  Future<UrpSecureToken> getToken(
    UrpSecureToken oldToken,
    UrpPublicKey publicKey,
  ) async {
    return ApiService().requestToken(oldToken, publicKey);
  }
}
