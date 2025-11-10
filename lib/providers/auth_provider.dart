import 'dart:async';
import 'package:flutter/material.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  Future<String?> get token async => await _authService.getStoredToken(); // Updated getter to return Future<String?>

  Future<String?> getAccessToken() async {
    return await _authService.getStoredToken();
  }

  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);
    
    try {
      final token = await _authService.getStoredToken();
      if (token != null) {
        // Validate token with backend
        final isValid = await _authService.validateToken();
        
        if (isValid) {
          // Token valid, get user info
          final user = await _authService.getCurrentUser();
          if (user != null) {
            _user = user;
            _setState(AuthState.authenticated);
          } else {
            await _authService.logout();
            _setState(AuthState.unauthenticated);
          }
        } else {
          // Token invalid, logout
          await _authService.logout();
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to check authentication status: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    
    try {
      final loginRequest = LoginRequest(usernameOrEmail: email, password: password);
      final response = await _authService.login(loginRequest);
      
      print('🔐 Login response - status: ${response.status}, isSuccess: ${response.isSuccess}');
      print('🔐 Login response - message: ${response.message}');
      
      if (response.isSuccess && response.accessToken != null) {
        _user = response.userInfo;
        await _authService.storeAuthData(response);
        _setState(AuthState.authenticated);
        return true;
      } else {
        // Use detailed error message from AuthResponse
        final errorMsg = response.getDetailedErrorMessage();
        print('🔐 Setting error: $errorMsg');
        _setError(errorMsg);
        print('🔐 Error message in provider: $_errorMessage');
        return false;
      }
    } catch (e) {
      String errorMessage;
      if (e is Exception) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng thử lại sau.';
      } else {
        errorMessage = 'Lỗi kết nối: ${e.toString()}';
      }
      print('🔐 Exception: $errorMessage');
      _setError(errorMessage);
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setState(AuthState.loading);
    
    try {
      final registerRequest = RegisterRequest(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      )..validate();
      final response = await _authService.register(registerRequest);
      
      if (response.isSuccess && response.accessToken != null) {
        _user = response.userInfo;
        await _authService.storeAuthData(response);
        _setState(AuthState.authenticated);
        return true;
      } else {
        // Use detailed error message from AuthResponse
        _setError(response.getDetailedErrorMessage());
        return false;
      }
    } catch (e) {
      String errorMessage;
      if (e is Exception) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng thử lại sau.';
      } else {
        errorMessage = 'Lỗi kết nối: ${e.toString()}';
      }
      _setError(errorMessage);
      return false;
    }
  }

  Future<bool> logout() async {
    _setState(AuthState.loading);
    
    try {
      final success = await _authService.logout();
      if (success) {
        _user = null;
        _setState(AuthState.unauthenticated);
      } else {
        _setError('Đăng xuất thất bại');
      }
      return success;
    } catch (e) {
      _setError('Lỗi khi đăng xuất: $e');
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  int? get userId => _user?.id;
}
