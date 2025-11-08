import 'package:flutter/foundation.dart';

class ServerConfig {
  static const String productionApiUrl = 'https://api.ainnect.me/api';
  
  static const String developmentApiUrl = 'http://10.0.2.2:8080/api';
  
  static String get baseUrl {
    if (kReleaseMode) {
      return productionApiUrl;
    } else {
      return developmentApiUrl;
    }
  }
  
  static String getBaseUrl(String ip, int port) {
    return baseUrl;
  }
  
  static String get baseUrlWithoutApi {
    return baseUrl.replaceAll('/api', '');
  }
}