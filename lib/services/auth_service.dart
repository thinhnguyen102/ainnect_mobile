import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<AuthResponse> login(LoginRequest request) async {
    final endpoint = '${Constants.baseUrl}/auth/login';
    final requestBody = jsonEncode(request.toJson());
    final headers = {
      'Content-Type': 'application/json',
    };
    
    Logger.debug('Attempting login with username/email: ${request.usernameOrEmail}');
    Logger.request('POST', endpoint, headers: headers, body: requestBody);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: requestBody,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('POST', endpoint, response.statusCode, 
        body: response.body, 
        headers: response.headers
      );

      // Decode response body with UTF-8 encoding
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      
      // Check if response is successful (status code 200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.isSuccess && authResponse.accessToken != null) {
          Logger.debug('Login successful for user: ${authResponse.userInfo?.displayName}');
          await storeAuthData(authResponse);
          return authResponse;
        } else {
          Logger.error('Login failed', error: authResponse.message ?? 'Unknown error');
          return authResponse;
        }
      } else {
        // Error response (400, 500, etc.) - parse error fields
        Logger.error('Login failed with status ${response.statusCode}', error: data['message']);
        
        // Extract error message - handle both direct message and nested in exception
        String errorMessage = data['message'] ?? 'Đăng nhập thất bại';
        
        // If it's a RuntimeException, extract the actual message
        if (errorMessage.contains('RuntimeException:')) {
          errorMessage = errorMessage.replaceAll('RuntimeException:', '').trim();
        }
        
        return AuthResponse(
          status: data['status'] ?? response.statusCode,
          error: data['error'] ?? 'Error',
          message: errorMessage,
          details: data['details'],
        );
      }
    } catch (e, stackTrace) {
      Logger.networkError('POST', endpoint, e);
      Logger.error(
        'Login request failed',
        error: e,
        stackTrace: stackTrace,
      );
      
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = e.message ?? 'Không thể kết nối đến server. Vui lòng thử lại sau.';
      } else {
        errorMessage = 'Lỗi kết nối: ${e.toString()}';
      }
      
      return AuthResponse(
        status: 500,
        error: 'Network Error',
        message: errorMessage,
      );
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final endpoint = '${Constants.baseUrl}/auth/register';
    final requestBody = jsonEncode(request.toJson());
    final headers = {
      'Content-Type': 'application/json',
    };
    
    Logger.debug('Attempting registration for email: ${request.email}');
    Logger.request('POST', endpoint, headers: headers, body: requestBody);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: requestBody,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('POST', endpoint, response.statusCode, 
        body: response.body, 
        headers: response.headers
      );

      // Decode response body with UTF-8 encoding
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      
      // Check if response is successful (status code 200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.isSuccess && authResponse.accessToken != null) {
          Logger.debug('Registration successful for user: ${authResponse.userInfo?.displayName}');
          await storeAuthData(authResponse);
          return authResponse;
        } else {
          Logger.error('Registration failed', error: authResponse.message ?? 'Unknown error');
          return authResponse;
        }
      } else {
        // Error response (400, 500, etc.) - parse error fields
        Logger.error('Registration failed with status ${response.statusCode}', error: data['message']);
        
        // Extract error message - handle both direct message and nested in exception
        String errorMessage = data['message'] ?? 'Đăng ký thất bại';
        
        // If it's a RuntimeException, extract the actual message
        if (errorMessage.contains('RuntimeException:')) {
          errorMessage = errorMessage.replaceAll('RuntimeException:', '').trim();
        }
        
        return AuthResponse(
          status: data['status'] ?? response.statusCode,
          error: data['error'] ?? 'Error',
          message: errorMessage,
          details: data['details'],
        );
      }
    } catch (e, stackTrace) {
      Logger.networkError('POST', endpoint, e);
      Logger.error(
        'Registration request failed',
        error: e,
        stackTrace: stackTrace,
      );
      
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = e.message ?? 'Không thể kết nối đến server. Vui lòng thử lại sau.';
      } else {
        errorMessage = 'Lỗi kết nối: ${e.toString()}';
      }
      
      return AuthResponse(
        status: 500,
        error: 'Network Error',
        message: errorMessage,
      );
    }
  }

  Future<User?> getCurrentUser() async {
    final endpoint = '${Constants.baseUrl}/auth/me';
    Logger.debug('Fetching current user info');
    
    try {
      final token = await getStoredToken();
      if (token == null) {
        Logger.debug('No stored token found');
        return null;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      Logger.request('GET', endpoint, headers: headers);

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, 
        body: response.body, 
        headers: response.headers
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        Logger.debug('Successfully fetched user info: ${user.displayName}');
        return user;
      } else {
        Logger.error(
          'Failed to get current user',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        await logout();
        return null;
      }
    } catch (e, stackTrace) {
      Logger.networkError('GET', endpoint, e);
      Logger.error(
        'Error fetching current user',
        error: e,
        stackTrace: stackTrace,
      );
      await logout();
      return null;
    }
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> storeAuthData(AuthResponse response) async {
    if (response.accessToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.accessToken!);
      
      if (response.userInfo != null) {
        await prefs.setString(_userKey, jsonEncode(response.userInfo!.toJson()));
      }
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getStoredToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> validateToken() async {
    final endpoint = '${Constants.baseUrl}/auth/validate';
    Logger.debug('Validating stored token');
    
    try {
      final token = await getStoredToken();
      if (token == null) {
        Logger.debug('No stored token found');
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      Logger.request('GET', endpoint, headers: headers);

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, 
        body: response.body, 
        headers: response.headers
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isValid = data['valid'] == true;
        Logger.debug('Token validation result: $isValid');
        
        if (!isValid) {
          // Token không hợp lệ, xóa local storage
          await logout();
        }
        
        return isValid;
      } else {
        Logger.error('Token validation failed with status: ${response.statusCode}');
        await logout();
        return false;
      }
    } catch (e, stackTrace) {
      Logger.networkError('GET', endpoint, e);
      Logger.error(
        'Error validating token',
        error: e,
        stackTrace: stackTrace,
      );
      // Nếu có lỗi network, giữ token để thử lại sau
      return false;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final endpoint = '${Constants.baseUrl}/users/change-password';
    final headers = await _getHeaders();
    final body = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
    
    Logger.request('PUT', endpoint, headers: headers, body: body);
    
    try {
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('PUT', endpoint, response.statusCode, body: response.body);

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200) {
        Logger.debug('Password changed successfully');
        return {
          'success': true,
          'message': data['message'] ?? 'Đổi mật khẩu thành công',
        };
      } else {
        Logger.error('Change password failed', error: data['message']);
        
        String errorMessage = data['message'] ?? 'Đổi mật khẩu thất bại';
        
        // Handle JWT expired error
        if (errorMessage.contains('JWT expired')) {
          errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
          await logout(); // Auto logout if token expired
        } else if (errorMessage.contains('Mật khẩu cũ không đúng')) {
          errorMessage = 'Mật khẩu cũ không đúng';
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e, stackTrace) {
      Logger.networkError('PUT', endpoint, e);
      Logger.error('Change password request failed', error: e, stackTrace: stackTrace);
      
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = e.message ?? 'Không thể kết nối đến server. Vui lòng thử lại sau.';
      } else {
        errorMessage = 'Lỗi kết nối: ${e.toString()}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  Future<bool> logout() async {
    try {
      final endpoint = '${Constants.baseUrl}/auth/logout';
      final headers = await _getHeaders();
      
      Logger.request('POST', endpoint, headers: headers);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      Logger.response('POST', endpoint, response.statusCode, 
        body: response.body, 
        headers: response.headers
      );

      // Xóa dữ liệu đăng nhập khỏi local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      return response.statusCode == 200;
    } catch (e) {
      Logger.networkError('POST', '${Constants.baseUrl}/auth/logout', e);
      return false;
    }
  }
}
