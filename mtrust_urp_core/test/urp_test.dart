import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_core/src/api_service.dart';

void main() {
  test('M-Trust API Test', () async {
    final fakeToken = UrpSecureToken();
    final fakePublicKey = UrpPublicKey();
    final apiService = ApiService();

    final response = await http.post(
      Uri.parse('${apiService.url}/api/device/v1/device-tokens'),
      headers: {
        'Authorization': base64Encode(fakePublicKey.value),
        'Content-Type': 'application/octet-stream',
      },
      body: fakeToken.writeToBuffer(),
    );

    if ([404, 500].contains(response.statusCode)) {
      fail('FAILED: Status code for API request: ${response.statusCode}');
    }
  });
}
