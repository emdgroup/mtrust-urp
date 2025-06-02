import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_core/src/api_service.dart';

void main() {
  // Test if the API is reachable and return a valid response.
  // As no token is provided, the API should return a 401.
  test('M-Trust API Test', () async {
    final apiService = ApiService();

    urpLogger.d('${apiService.url}/api/device/v1/device-tokens');

    final response = await http.post(
      Uri.parse('${apiService.url}/api/device/v1/device-tokens'),
    );

    expect(response.statusCode, 401);

  });
}
