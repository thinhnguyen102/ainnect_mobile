import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/logger.dart';

class QrLoginService {
  // Get QR login session info
  Future<Map<String, dynamic>> getSessionInfo(String sessionId, String token) async {
    final endpoint = '${Constants.baseUrl}/qr-login/session/$sessionId';
    Logger.debug('Getting QR login session info: $sessionId');

    try {
      Logger.debug('Sending GET request to: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Get session info failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to get session info');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during get session info',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Confirm QR login
  Future<Map<String, dynamic>> confirmLogin(String sessionId, String token) async {
    final endpoint = '${Constants.baseUrl}/qr-login/confirm';
    Logger.debug('Confirming QR login for session: $sessionId');

    try {
      Logger.debug('Sending POST request to: $endpoint');
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sessionId': sessionId,
        }),
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Confirm login failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to confirm login');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during confirm login',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
