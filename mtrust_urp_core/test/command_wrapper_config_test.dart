import 'package:flutter_test/flutter_test.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Minimal [CmdWrapper] test double: records the last [UrpCoreCommand] sent
/// and returns a canned [UrpResponse] (or throws a canned error), bypassing
/// any real transport. This exercises exactly the request-construction /
/// response-parsing logic added to [CmdWrapper] for device config support.
class _FakeCmdWrapper extends CmdWrapper {
  UrpCoreCommand? lastCommand;
  UrpResponse Function(UrpCoreCommand command)? onCommand;

  @override
  Future<UrpResponse> addCoreCmdToQueue(UrpCoreCommand command) async {
    lastCommand = command;
    final handler = onCommand;
    if (handler == null) {
      throw StateError('onCommand not set');
    }
    return handler(command);
  }
}

void main() {
  group('CmdWrapper.getConfig', () {
    test('sends urpGetConfig and parses UrpConfigResponse', () async {
      final wrapper = _FakeCmdWrapper();
      final canned = UrpConfigResponse(
        signature: List.filled(256, 0x11),
        config: UrpDeviceConfig(version: 1, cloudPresence: true),
      );
      wrapper.onCommand = (_) => UrpResponse(payload: canned.writeToBuffer());

      final result = await wrapper.getConfig();

      expect(wrapper.lastCommand!.command, UrpCommand.urpGetConfig);
      expect(result.config.version, 1);
      expect(result.config.cloudPresence, true);
      expect(result.signature.length, 256);
    });
  });

  group('CmdWrapper.setConfig', () {
    test('sends urpSetConfig with the signed payload attached', () async {
      final wrapper = _FakeCmdWrapper();
      final signedConfig = UrpSignedConfigPayload(
        signature: List.filled(256, 0x22),
        config: UrpDeviceConfig(version: 1, cloudPresence: true),
      );
      final canned = UrpConfigResponse(config: signedConfig.config);
      wrapper.onCommand = (_) => UrpResponse(payload: canned.writeToBuffer());

      final result = await wrapper.setConfig(signedConfig);

      expect(wrapper.lastCommand!.command, UrpCommand.urpSetConfig);
      expect(wrapper.lastCommand!.configPayload.config.cloudPresence, true);
      expect(result.config.cloudPresence, true);
    });
  });

  group('CmdWrapper.resetConfig', () {
    test('sends urpResetConfig with the signed reset payload attached',
        () async {
      final wrapper = _FakeCmdWrapper();
      final signedReset = UrpSignedConfigPayload(
        signature: List.filled(256, 0x33),
        config: UrpDeviceConfig(version: 1),
      );
      final canned = UrpConfigResponse(config: signedReset.config);
      wrapper.onCommand = (_) => UrpResponse(payload: canned.writeToBuffer());

      final result = await wrapper.resetConfig(signedReset);

      expect(wrapper.lastCommand!.command, UrpCommand.urpResetConfig);
      expect(result.config.version, 1);
    });
  });

  group('CmdWrapper.signChallenge', () {
    test('sends urpSignChallenge with nonce/deviceId and returns raw signature',
        () async {
      final wrapper = _FakeCmdWrapper();
      final signature = List.filled(256, 0xAA);
      wrapper.onCommand = (_) => UrpResponse(
            payload:
                UrpSignChallengeResponse(signature: signature).writeToBuffer(),
          );

      final result = await wrapper.signChallenge('nonce123', 'deviceABC');

      expect(wrapper.lastCommand!.command, UrpCommand.urpSignChallenge);
      expect(wrapper.lastCommand!.signChallengeParameters.nonce, 'nonce123');
      expect(
        wrapper.lastCommand!.signChallengeParameters.deviceId,
        'deviceABC',
      );
      expect(result, signature);
    });

    test('empty nonce signs SHA-256(deviceId) — nonce param is empty string',
        () async {
      final wrapper = _FakeCmdWrapper();
      wrapper.onCommand = (_) => UrpResponse(
            payload: UrpSignChallengeResponse(signature: List.filled(256, 0))
                .writeToBuffer(),
          );

      await wrapper.signChallenge('', 'deviceABC');

      expect(wrapper.lastCommand!.signChallengeParameters.nonce, '');
      expect(
        wrapper.lastCommand!.signChallengeParameters.deviceId,
        'deviceABC',
      );
    });
  });
}
