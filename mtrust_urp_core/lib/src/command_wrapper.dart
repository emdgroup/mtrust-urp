import 'dart:convert';

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
  Future<UrpSecureToken> getToken(
    UrpSecureToken oldToken,
    UrpPublicKey publicKey,
  ) async {
    return ApiService().requestToken(oldToken, publicKey);
  }

  // --------------------------------------------------------------------
  // Device configuration (urpGetConfig / urpSetConfig / urpResetConfig /
  // urpSignChallenge) — mirrors mtrust_py_sdk's ConfigMixin + OtaMixin.
  //
  // Security model:
  //  - setConfig()/resetConfig() accept a backend-signed config payload;
  //    the device verifies the backend's signature before applying it.
  //  - getConfig() returns the device's current config signed by the
  //    device's own private key, so the caller/backend can verify
  //    authenticity.
  //  - signChallenge() asks the device to sign a nonce with its own
  //    private key, which never leaves the device — this is how the
  //    device proves its identity to the backend (see [ConfigApiService]).
  // --------------------------------------------------------------------

  /// Reads the device's current configuration.
  ///
  /// Returns the config signed by the device's own private key
  /// (`UrpConfigResponse` — access `.config` / `.signature`), so the
  /// caller can verify authenticity against the device's known public key.
  Future<UrpConfigResponse> getConfig() async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpGetConfig,
    );
    final res = await addCoreCmdToQueue(cmd);
    return UrpConfigResponse.fromBuffer(res.payload);
  }

  /// Writes a backend-signed configuration to the device.
  ///
  /// [signedConfig] must be obtained from [signAndSetConfig] or directly
  /// from [ConfigApiService.signConfig] — the device will reject any
  /// payload not signed by its trusted backend key.
  Future<UrpConfigResponse> setConfig(
    UrpSignedConfigPayload signedConfig,
  ) async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpSetConfig,
      configPayload: signedConfig,
    );
    final res = await addCoreCmdToQueue(cmd);
    return UrpConfigResponse.fromBuffer(res.payload);
  }

  /// Resets the device configuration to factory defaults.
  ///
  /// [signedReset] must be a backend-signed payload, same trust model as
  /// [setConfig].
  Future<UrpConfigResponse> resetConfig(
    UrpSignedConfigPayload signedReset,
  ) async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpResetConfig,
      configPayload: signedReset,
    );
    final res = await addCoreCmdToQueue(cmd);
    return UrpConfigResponse.fromBuffer(res.payload);
  }

  /// Asks the device to sign `SHA-256(nonce + deviceId)` with its own
  /// RSA-2048 private key. The private key never leaves the device.
  ///
  /// Used both to authenticate the device to the config-signing backend
  /// (via [ConfigApiService.requestChallenge] / [ConfigApiService.signConfig])
  /// and, with an empty [nonce], to prove key ownership for the initial
  /// `/challenge` request (signs `SHA-256(deviceId)`).
  ///
  /// Returns the raw signature bytes (RSA-2048 PKCS1v15, 256 bytes).
  ///
  /// RSA-2048 signing takes several seconds on the ESP32-S3 — pass a
  /// generous timeout when awaiting this call (the default core command
  /// timeout of 5s is usually NOT enough; callers typically use ~30s).
  Future<List<int>> signChallenge(String nonce, String deviceId) async {
    final cmd = UrpCoreCommand(
      command: UrpCommand.urpSignChallenge,
      signChallengeParameters: UrpSignChallengeParameters(
        nonce: nonce,
        deviceId: deviceId,
      ),
    );
    final res = await addCoreCmdToQueue(cmd);
    return UrpSignChallengeResponse.fromBuffer(res.payload).signature;
  }

  /// High-level helper: sign a config with the backend and apply it to the
  /// device in one step.
  ///
  /// Mirrors `mtrust_py_sdk`'s `ConfigMixin.sign_and_set_config`. Performs:
  ///
  ///  1. Sign `deviceId` (UTF-8 bytes) via [signChallenge] with an empty
  ///     nonce, and call `GET /challenge` to obtain a one-time nonce.
  ///  2. Sign `nonce + deviceId` via [signChallenge].
  ///  3. POST the structured [configJson] to
  ///     `{otaServiceUrl}/device/config/sign?device_id=&nonce=&sig=`.
  ///  4. Apply the backend-signed result via [setConfig].
  ///
  /// The device's private key never leaves the device — the SDK is a pure
  /// transport layer; identity is proven cryptographically via
  /// challenge-response.
  ///
  /// [configJson] should match the shape of `UrpDeviceConfig` — see
  /// [ConfigApiService.signConfig] for the full field list.
  ///
  /// Throws [ConfigValidationException] if the backend rejects the config
  /// due to a guardrail violation (HTTP 422).
  Future<UrpConfigResponse> signAndSetConfig({
    required Map<String, dynamic> configJson,
    required String otaServiceUrl,
    required String deviceId,
    required String devicePublicKeyPem,
  }) async {
    final api = ConfigApiService(otaServiceUrl);

    // Step 1: prove key ownership — sign deviceId with nonce="" (device
    // signs SHA-256("" + deviceId) = SHA-256(deviceId)), then request the
    // real challenge nonce.
    final preSigBytes = await signChallenge('', deviceId);
    final preSig = base64Encode(preSigBytes);

    final nonce = await api.requestChallenge(
      deviceId: deviceId,
      publicKeyPem: devicePublicKeyPem,
      sig: preSig,
    );

    // Step 2: sign nonce + deviceId to authenticate the actual config-sign
    // request.
    final nonceSigBytes = await signChallenge(nonce, deviceId);
    final nonceSig = base64Encode(nonceSigBytes);

    // Step 3: backend validates, encodes, and signs the config.
    final signedConfig = await api.signConfig(
      deviceId: deviceId,
      nonce: nonce,
      sig: nonceSig,
      configJson: configJson,
    );

    // Step 4: apply to the device.
    return setConfig(signedConfig);
  }
}
