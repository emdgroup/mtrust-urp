import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Service for API calls
class ApiService {

  /// M-Trust API URL
  final url = 'https://api.dev.mtrust.io';
  
  /// Fetch new [UrpSecureToken] from M-Trust API
  Future<UrpSecureToken?> requestToken(
    UrpSecureToken requestToken, 
    UrpPublicKey publicKey,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$url/api/device/v1/device-tokens'),
        headers: {
          'Authorization': base64Encode(publicKey.value),
          'Content-Type': 'application/octet-stream',
        },
        body: requestToken.writeToBuffer(),
      );

      final token = UrpSecureToken.fromBuffer(res.bodyBytes);
      return token;
    } catch (e) {
      urpLogger.e('Failed to fetch token! $e');
      return null;
    }
  }

}
