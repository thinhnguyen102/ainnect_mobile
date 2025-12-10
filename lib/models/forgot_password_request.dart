class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
      };
}

class VerifyOtpRequest {
  final String email;
  final String otpCode;

  VerifyOtpRequest({
    required this.email,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'otpCode': otpCode.trim(),
      };
}

class ResetPasswordRequest {
  final String email;
  final String otpCode;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'otpCode': otpCode.trim(),
        'newPassword': newPassword,
      };
}

class ForgotPasswordResponse {
  final String message;
  final String? email;
  final int? expiresInSeconds;

  ForgotPasswordResponse({
    required this.message,
    this.email,
    this.expiresInSeconds,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] as String,
      email: json['email'] as String?,
      expiresInSeconds: json['expiresInSeconds'] as int?,
    );
  }
}

class VerifyOtpResponse {
  final String message;
  final bool isValid;

  VerifyOtpResponse({
    required this.message,
    required this.isValid,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] as String,
      isValid: json['isValid'] as bool? ?? false,
    );
  }
}

class ResetPasswordResponse {
  final String message;
  final bool success;

  ResetPasswordResponse({
    required this.message,
    required this.success,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] as String,
      success: json['success'] as bool? ?? false,
    );
  }
}

