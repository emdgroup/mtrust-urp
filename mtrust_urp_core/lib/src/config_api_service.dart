import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Service for the device-config signing backend endpoints
/// (`GET /challenge`, `POST /device/config/sign`).
///
/// This is a *device-authenticates-to-service* flow, distinct from
/// `ApiService`'s device-token exchange: the device proves its identity by
/// signing a server-issued nonce with its own RSA private key (via
/// `CmdWrapper.signChallenge`), never exposing the key itself. The backend
/// then signs the validated config with its own key, and the device
/// verifies that signature before applying the config
/// (`CmdWrapper.setConfig`).
///
/// Mirrors mtrust_py_sdk's
/// `ConfigMixin.sign_and_set_config`.
class ConfigApiService {
  /// Creates a new instance of [ConfigApiService] pointed at [baseUrl].
  ///
  /// An [http.Client] may be injected for testing; defaults to a fresh
  /// `http.Client` per call otherwise (matching `ApiService`'s style).
  ConfigApiService(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  /// Base URL of the OTA/device-services backend (no trailing slash),
  /// e.g. `https://mtrust-ota-dev.<region>.azurecontainerapps.io`.
  final String baseUrl;

  final http.Client _client;

  /// GET `/challenge?device_id=&public_key=&sig=` — request a one-time
  /// nonce for the device-config signing flow.
  ///
  /// [sig] must be the device's signature over `deviceId` (UTF-8 bytes),
  /// base64-encoded (obtained via `CmdWrapper.signChallenge` with an empty
  /// nonce — i.e. `signChallenge('', deviceId)`, which signs
  /// `SHA-256(deviceId)`).
  Future<String> requestChallenge({
    required String deviceId,
    required String publicKeyPem,
    required String sig,
  }) async {
    final uri = Uri.parse('$baseUrl/challenge').replace(
      queryParameters: {
        'device_id': deviceId,
        'public_key': publicKeyPem,
        'sig': sig,
      },
    );
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      urpLogger
          .e('Challenge request failed with status code ${res.statusCode}');
      throw ApiException(
        errorCode: res.statusCode,
        errorMessage: res.body,
      );
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    return body['nonce'] as String;
  }

  /// POST `/device/config/sign?device_id=&nonce=&sig=` — validate, encode,
  /// and backend-sign a config.
  ///
  /// [sig] must be the device's signature over `nonce + deviceId` (UTF-8
  /// bytes), base64-encoded (obtained via
  /// `signChallenge(nonce, deviceId)`).
  ///
  /// [configJson] is the structured JSON body matching the shape of
  /// `UrpDeviceConfig` (version, scan, button, auto_update, ble_enabled,
  /// usb_enabled, wifi_enabled, auto_token_refresh, token_refresh_threshold,
  /// token_refresh_expiry_margin_s, cloud_presence). Fields omitted use
  /// backend defaults.
  ///
  /// Returns the backend-signed [UrpSignedConfigPayload], ready to pass to
  /// [CmdWrapper.setConfig] / [CmdWrapper.resetConfig].
  ///
  /// Throws [ConfigValidationException] on HTTP 422 (guardrail violation),
  /// or [ApiException] for any other non-2xx response.
  Future<UrpSignedConfigPayload> signConfig({
    required String deviceId,
    required String nonce,
    required String sig,
    required Map<String, dynamic> configJson,
  }) async {
    final uri = Uri.parse('$baseUrl/device/config/sign').replace(
      queryParameters: {
        'device_id': deviceId,
        'nonce': nonce,
        'sig': sig,
      },
    );
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(configJson),
    );

    if (res.statusCode == 422) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      throw ConfigValidationException(
        code: (body['code'] as String?) ?? 'CFG_ERR_UNKNOWN',
        message: (body['error'] as String?) ?? 'Config validation failed',
      );
    }

    if (res.statusCode != 200) {
      urpLogger
          .e('Config sign request failed with status code ${res.statusCode}');
      throw ApiException(
        errorCode: res.statusCode,
        errorMessage: res.body,
      );
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final signature = base64Decode(body['signature'] as String);
    final configBytes = base64Decode(body['config_bytes_b64'] as String);

    return UrpSignedConfigPayload(
      signature: signature,
      config: UrpDeviceConfig.fromBuffer(configBytes),
    );
  }
}
