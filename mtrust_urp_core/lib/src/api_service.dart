import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Service for API calls
class ApiService {

  /// M-Trust API URL
  final url = const String.fromEnvironment('API_URL', defaultValue: 'https://api.mtrust.io');
  
  /// Fetch new [UrpSecureToken] from M-Trust API
  Future<UrpSecureToken?> requestToken(
    UrpSecureToken requestToken, 
    UrpPublicKey publicKey,
  ) async {
    final res = await http.post(
      Uri.parse('$url/api/device/v1/device-tokens'),
      headers: {
        'Authorization': base64Encode(publicKey.value),
        'Content-Type': 'application/octet-stream',
      },
      body: requestToken.writeToBuffer(),
    );

    if(res.statusCode != 200) {
      urpLogger.e('API request failed with status code ${res.statusCode}');
      final body = json.decode(res.body) as Map<String, dynamic>;
      throw ApiException(
        errorCode: res.statusCode,
        errorMessage: body['message'].toString(),
      );
    }
    final token = UrpSecureToken.fromBuffer(res.bodyBytes);
    return token;
  }

}
