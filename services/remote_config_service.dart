import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteConfigService {
  static const String configUrl =
      'https://raw.githubusercontent.com/oddproblem/authguard-config/main/app-config.json';

  static Future<Map<String, dynamic>> fetchRemoteConfig() async {
    try {
      final response = await http.get(Uri.parse(configUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Remote config fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Remote config fetch error: $e');
    }

    // Default config if failed
    return {
      "app_enabled": true,
      "message": "Unable to reach server, assuming app is enabled."
    };
  }
}
