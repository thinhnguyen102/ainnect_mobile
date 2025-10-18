import 'dart:developer' as developer;

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
}
