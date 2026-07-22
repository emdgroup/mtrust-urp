import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

void main() {
  group('ConfigApiService.requestChallenge', () {
    test('sends device_id/public_key/sig and returns the nonce', () async {
      Uri? capturedUri;

      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode({'nonce': 'abc123', 'expires_in': 120}),
          200,
        );
      });

      final api = ConfigApiService('https://ota.example.com', client: client);
      final nonce = await api.requestChallenge(
        deviceId: 'deadbeef',
        publicKeyPem:
            '-----BEGIN PUBLIC KEY-----\nAAAA\n-----END PUBLIC KEY-----',
        sig: 'c2lnbmF0dXJl',
      );

      expect(nonce, 'abc123');
      expect(capturedUri!.path, '/challenge');
      expect(capturedUri!.queryParameters['device_id'], 'deadbeef');
      expect(capturedUri!.queryParameters['sig'], 'c2lnbmF0dXJl');
      expect(
        capturedUri!.queryParameters['public_key'],
        '-----BEGIN PUBLIC KEY-----\nAAAA\n-----END PUBLIC KEY-----',
      );
    });

    test('throws ApiException on non-200 response', () async {
      final client = MockClient((request) async {
        return http.Response('{"error": "Device not registered"}', 403);
      });

      final api = ConfigApiService('https://ota.example.com', client: client);

      expect(
        () => api.requestChallenge(
          deviceId: 'deadbeef',
          publicKeyPem: 'pem',
          sig: 'sig',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ConfigApiService.signConfig', () {
    test('parses signature and config_bytes_b64 into UrpSignedConfigPayload',
        () async {
      // A minimal UrpDeviceConfig{version: 1} encoded: tag=0x08 value=0x01
      final configBytes = [0x08, 0x01];
      final configBytesB64 = base64Encode(configBytes);
      final signatureB64 = base64Encode(List.filled(256, 0xAB));

      Uri? capturedUri;
      String? capturedBody;

      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedBody = request.body;
        return http.Response(
          jsonEncode({
            'signature': signatureB64,
            'config_bytes_b64': configBytesB64,
            'config': {'version': 1},
          }),
          200,
        );
      });

      final api = ConfigApiService('https://ota.example.com', client: client);
      final result = await api.signConfig(
        deviceId: 'deadbeef',
        nonce: 'nonce123',
        sig: 'sig456',
        configJson: {'version': 1},
      );

      expect(capturedUri!.path, '/device/config/sign');
      expect(capturedUri!.queryParameters['device_id'], 'deadbeef');
      expect(capturedUri!.queryParameters['nonce'], 'nonce123');
      expect(capturedUri!.queryParameters['sig'], 'sig456');
      expect(jsonDecode(capturedBody!), {'version': 1});

      expect(result.config.version, 1);
      expect(result.signature.length, 256);
      expect(result.signature, List.filled(256, 0xAB));
    });

    test('throws ConfigValidationException on 422 with code/error', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'CFG_ERR_SCAN_TIMEOUT_RANGE',
            'error': 'scan.timeout_ms must be between 0 and 60000',
          }),
          422,
        );
      });

      final api = ConfigApiService('https://ota.example.com', client: client);

      try {
        await api.signConfig(
          deviceId: 'deadbeef',
          nonce: 'nonce123',
          sig: 'sig456',
          configJson: {
            'version': 1,
            'scan': {'timeout_ms': 999999},
          },
        );
        fail('expected ConfigValidationException');
      } on ConfigValidationException catch (e) {
        expect(e.code, 'CFG_ERR_SCAN_TIMEOUT_RANGE');
        expect(e.message, contains('scan.timeout_ms'));
      }
    });

    test('throws ApiException on other non-200 responses', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final api = ConfigApiService('https://ota.example.com', client: client);

      expect(
        () => api.signConfig(
          deviceId: 'deadbeef',
          nonce: 'nonce123',
          sig: 'sig456',
          configJson: {'version': 1},
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
