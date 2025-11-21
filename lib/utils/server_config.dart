import 'package:flutter/foundation.dart';

class ServerConfig {
  // Define environment URLs
  static const String productionApiUrl = 'https://api.ainnect.me/api';
  static const String stagingApiUrl = 'https://api-stg.ainnect.me/api';
  static const String developmentApiUrl = 'http://10.0.2.2:8080/api';
  
  // Get environment from dart-define
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static String get baseUrl {
    // Check dart-define environment first
    switch (environment.toLowerCase()) {
      case 'production':
      case 'prod':
        return productionApiUrl;
      case 'staging':
      case 'stg':
        return stagingApiUrl;
      case 'development':
      case 'dev':
      default:
        return developmentApiUrl;
    }
  }
  
  static String getBaseUrl(String ip, int port) {
    return baseUrl;
  }
  
  static String get baseUrlWithoutApi {
    return baseUrl.replaceAll('/api', '');
  }
  
  static String get currentEnvironment => environment;
}