import 'package:flutter/foundation.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_core/src/api_service.dart';

/// Wrapper for the core commands, these commands need to be wrapped in a
/// device specific Command Wrapper before they can be send to a device.
class CmdWrapper extends ChangeNotifier {

  /// Command to ping the device.
  UrpCoreCommand ping() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpPing,
    );
  }

  /// Command to get the device info.
  UrpCoreCommand info() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpGetInfo,
    );
  }

  /// Command to get the power state of the device.
  UrpCoreCommand getPower() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpGetPower,
    );
  }

  /// Command to set the device name.
  UrpCoreCommand setName(String name) {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpSetName,
      setNameParameters: UrpSetNameParameters(name: name),
    );
  }

  /// Command to get the device name.
  UrpCoreCommand getName() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpGetName,
    );
  }

  /// Command to pair a device.
  UrpCoreCommand pair() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpPair,
    );
  }

  /// Command to unpair a device.
  UrpCoreCommand unpair() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpUnpair,
    );
  }

  @Deprecated(
    'This method is deprecated and will be removed in a future release',
  )
  /// Command to start an access point for the firmware update.
  UrpCoreCommand startAP(String ssid, String apk) {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpStartAp,
      apParameters: UrpApParamters(ssid: ssid, password: apk),
    );
  }

  @Deprecated(
    'This method is deprecated and will be removed in a future release',
  )
  /// Command to stop the access point.
  UrpCoreCommand stopAP() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpStopAp,
    );
  }

  @Deprecated(
    'This method is deprecated and will be removed in a future release',
  )
  /// Command to connect to an access point.
  UrpCoreCommand connectAP(String ssid, String apk) {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpConnectAp,
      apParameters: UrpApParamters(ssid: ssid, password: apk),
    );
  }

  @Deprecated(
    'This method is deprecated and will be removed in a future release',
  )
  /// Command to disconnect from an access point.
  UrpCoreCommand disconnectAP() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpDisconnectAp,
    );
  }

  /// Command to start DFU.
  UrpCoreCommand startDFU() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpStartDfu,
    );
  }

  /// Command to stop DFU.
  UrpCoreCommand stopDFU() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpStopDfu,
    );
  }

  /// Command to put the device to sleep mode. 
  /// It will disconnect from the device.
  UrpCoreCommand sleep() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpSleep,
    );
  }

  /// Command to turn the device off. It will disconnect from the device.
  UrpCoreCommand off() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpOff,
    );
  }

  /// Command to reboot the device. It will disconnect from the device.
  UrpCoreCommand reboot() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpReboot,
    );
  }

  /// Command to prevent the device from going to sleep mode.
  UrpCoreCommand stayAwake() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpStayAwake,
    );
  }

  /// Command to get the public key of the device. 
  UrpCoreCommand getPublicKey() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpGetPublicKey,
    );
  }

  /// Command to get the device id
  UrpCoreCommand getDeviceId() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpGetDeviceId,
    );
  }

  /// Command to identify a reader. Triggers the LED to identify the device.
  UrpCoreCommand identify() {
    return UrpCoreCommand(
      command: wrapper.UrpCommand.urpIdentify,
    );
  }
}
