import 'server_config.dart';

class Constants {
  static String get baseUrl => ServerConfig.baseUrl;
  
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userEndpoint = '/auth/user';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const Duration requestTimeout = Duration(seconds: 30);
}