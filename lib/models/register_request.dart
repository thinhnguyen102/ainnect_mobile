import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String displayName;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.displayName,
  });

  void validate() {
    if (username.isEmpty) {
      throw ArgumentError('Username không được để trống');
    }
    if (email.isEmpty) {
      throw ArgumentError('Email không được để trống');
    }
    if (password.isEmpty) {
      throw ArgumentError('Mật khẩu không được để trống');
    }
    if (displayName.isEmpty) {
      throw ArgumentError('Tên hiển thị không được để trống');
    }
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

