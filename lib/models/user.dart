import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool isActive;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, displayName: $displayName}';
  }
}

