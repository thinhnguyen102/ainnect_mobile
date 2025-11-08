import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final User? userInfo;
  final int? status;
  final String? error;
  final String? message;
  final Map<String, dynamic>? details;

  const AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.userInfo,
    this.status,
    this.error,
    this.message,
    this.details,
  });

  bool get isSuccess => status == null && accessToken != null;
  bool get isError => status != null && status! >= 400;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
  
  /// Get detailed error message for display
  String getDetailedErrorMessage() {
    if (message == null) return 'Đã xảy ra lỗi không xác định';
    
    // If there are validation details, format them nicely
    if (details != null && details!.isNotEmpty) {
      final buffer = StringBuffer();
      
      // Add main message if it's not just generic "Validation Failed"
      if (message != 'Dữ liệu đầu vào không hợp lệ') {
        buffer.writeln(message);
      }
      
      // Add each validation error on a new line
      details!.forEach((field, errorMsg) {
        final fieldName = _getFieldDisplayName(field);
        buffer.writeln('• $fieldName: $errorMsg');
      });
      
      return buffer.toString().trim();
    }
    
    // Return the message as-is
    return message!;
  }
  
  /// Convert field names to Vietnamese display names
  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'username':
        return 'Tên đăng nhập';
      case 'email':
        return 'Email';
      case 'password':
        return 'Mật khẩu';
      case 'displayName':
        return 'Tên hiển thị';
      case 'firstName':
        return 'Tên';
      case 'lastName':
        return 'Họ';
      default:
        return field;
    }
  }
}

