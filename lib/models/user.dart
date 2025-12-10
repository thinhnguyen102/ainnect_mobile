import 'package:json_annotation/json_annotation.dart';
import 'badge.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? coverUrl;
  final String? phone;
  final String? bio;
  final String? gender;
  final String? birthday;
  final bool isActive;
  final List<Badge>? badges;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.coverUrl,
    this.phone,
    this.bio,
    this.gender,
    this.birthday,
    required this.isActive,
    this.badges,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      isActive: json['isActive'] as bool,
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'phone': phone,
      'bio': bio,
      'gender': gender,
      'birthday': birthday,
      'isActive': isActive,
    };
    if (badges != null) {
      data['badges'] = badges!.map((b) => b.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, displayName: $displayName}';
  }
}

