import 'dart:developer' as developer;
import 'dart:convert';

class Logger {
  static void debug(String message) {
    developer.log(
      message,
      name: 'DEBUG',
      time: DateTime.now(),
    );
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  static void api(String method, String endpoint, {int? statusCode, String? response, Object? error}) {
    final buffer = StringBuffer();
    buffer.writeln('API Call:');
    buffer.writeln('  Method: $method');
    buffer.writeln('  Endpoint: $endpoint');
    
    if (statusCode != null) {
      buffer.writeln('  Status Code: $statusCode');
    }
    
    if (response != null) {
      buffer.writeln('  Response: $response');
    }
    
    if (error != null) {
      buffer.writeln('  Error: $error');
    }

    developer.log(
      buffer.toString(),
      name: 'API',
      error: error,
      time: DateTime.now(),
    );
  }

  static void request(String method, String endpoint, {Map<String, String>? headers, String? body}) {
    final buffer = StringBuffer();
    buffer.writeln('🚀 REQUEST:');
    buffer.writeln('  Method: $method');
    buffer.writeln('  URL: $endpoint');
    buffer.writeln('  Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('  Headers:');
      headers.forEach((key, value) {
        // Mask sensitive headers
        if (key.toLowerCase() == 'authorization') {
          buffer.writeln('    $key: ${value.length > 20 ? '${value.substring(0, 20)}...' : value}');
        } else {
          buffer.writeln('    $key: $value');
        }
      });
    }
    
    if (body != null && body.isNotEmpty) {
      buffer.writeln('  Body:');
      try {
        // Try to format JSON for better readability
        final jsonData = jsonDecode(body);
        final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonData);
        buffer.writeln('    $formattedJson');
      } catch (e) {
        // If not JSON, just show the raw body
        buffer.writeln('    $body');
      }
    }

    developer.log(
      buffer.toString(),
      name: 'REQUEST',
      time: DateTime.now(),
    );
  }

  static void response(String method, String endpoint, int statusCode, {String? body, Map<String, String>? headers}) {
    final buffer = StringBuffer();
    buffer.writeln('📥 RESPONSE:');
    buffer.writeln('  Method: $method');
    buffer.writeln('  URL: $endpoint');
    buffer.writeln('  Status Code: $statusCode');
    buffer.writeln('  Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('  Headers:');
      headers.forEach((key, value) {
        buffer.writeln('    $key: $value');
      });
    }
    
    if (body != null && body.isNotEmpty) {
      buffer.writeln('  Body:');
      try {
        // Try to format JSON for better readability
        final jsonData = jsonDecode(body);
        final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonData);
        buffer.writeln('    $formattedJson');
      } catch (e) {
        // If not JSON, just show the raw body
        buffer.writeln('    $body');
      }
    }

    developer.log(
      buffer.toString(),
      name: 'RESPONSE',
      time: DateTime.now(),
    );
  }

  static void networkError(String method, String endpoint, Object error) {
    final buffer = StringBuffer();
    buffer.writeln('❌ NETWORK ERROR:');
    buffer.writeln('  Method: $method');
    buffer.writeln('  URL: $endpoint');
    buffer.writeln('  Error: $error');
    buffer.writeln('  Timestamp: ${DateTime.now().toIso8601String()}');

    developer.log(
      buffer.toString(),
      name: 'NETWORK_ERROR',
      error: error,
      time: DateTime.now(),
    );
  }
}
