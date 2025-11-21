import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class UrlHelper {
  static const List<String> _localPrefixes = [
    'file://',
    '/data/',
    '/storage/',
    'content://',
  ];

  static Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  static bool _isLocalDevicePath(String url) {
    final lower = url.toLowerCase();
    for (final prefix in _localPrefixes) {
      if (lower.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }

  static String? fixImageUrl(String? url) {
    if (url == null) {
      return null;
    }

    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (_isLocalDevicePath(trimmed)) {
      return null;
    }

    if (trimmed.startsWith('http://localhost')) {
      return trimmed.replaceFirst('http://localhost', 'http://10.0.2.2');
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }

    if (trimmed.startsWith('/')) {
      return '${Constants.baseUrl}$trimmed';
    }

    return trimmed;
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getAuthToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }
}