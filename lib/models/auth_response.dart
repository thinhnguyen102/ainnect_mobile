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
}

