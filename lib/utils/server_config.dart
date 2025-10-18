import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  static const String _serverIpKey = 'server_ip';
  static const String _serverPortKey = 'server_port';
  static const String defaultServerIp = '10.0.2.2';
  static const int defaultServerPort = 8080;

  static Future<void> saveServerConfig(String ip, int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverIpKey, ip);
    await prefs.setInt(_serverPortKey, port);
  }

  static Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverIpKey) ?? defaultServerIp;
  }

  static Future<int> getServerPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_serverPortKey) ?? defaultServerPort;
  }

  static String getBaseUrl(String ip, int port) {
    return 'http://$ip:$port/api';
  }
}