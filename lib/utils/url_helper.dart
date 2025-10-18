import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class UrlHelper {
  static Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    // Nếu là URL đầy đủ, thay thế localhost bằng 10.0.2.2 cho Android Emulator
    if (url.startsWith('http://localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }

    // Nếu là đường dẫn tương đối, thêm baseUrl
    if (url.startsWith('/')) {
      return '${Constants.baseUrl}$url';
    }

    return url;
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getAuthToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }
}