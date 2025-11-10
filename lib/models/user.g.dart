// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
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
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'coverUrl': instance.coverUrl,
  'phone': instance.phone,
  'bio': instance.bio,
  'gender': instance.gender,
  'birthday': instance.birthday,
  'isActive': instance.isActive,
};
