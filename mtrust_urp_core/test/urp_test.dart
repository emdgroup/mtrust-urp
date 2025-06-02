import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_core/src/api_service.dart';

void main() {
  // Test if the API is reachable and returns a valid response.
  // As no token is provided, the API should return a 401.
  test('M-Trust API Test', () async {
    final apiService = ApiService();

    final response = await http.post(
      Uri.parse('${apiService.url}/api/device/v1/device-tokens'),
    );

    urpLogger.d('API Response: ${response.statusCode}');

    expect(response.statusCode, 401);
  });
}
