// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  visibility: json['privacy'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  coverImageUrl: json['coverUrl'] as String?,
  requiresApproval: json['requiresApproval'] as bool,
  ownerId: (json['ownerId'] as num).toInt(),
  ownerUsername: json['ownerUsername'] as String,
  ownerDisplayName: json['ownerDisplayName'] as String,
  memberCount: (json['memberCount'] as num).toInt(),
  hasPendingRequest: json['hasPendingRequest'] as bool,
  userRole: json['userRole'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  owner: json['owner'] as bool,
  member: json['member'] as bool,
  moderator: json['moderator'] as bool,
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'privacy': instance.visibility,
  'avatarUrl': instance.avatarUrl,
  'coverUrl': instance.coverImageUrl,
  'requiresApproval': instance.requiresApproval,
  'ownerId': instance.ownerId,
  'ownerUsername': instance.ownerUsername,
  'ownerDisplayName': instance.ownerDisplayName,
  'memberCount': instance.memberCount,
  'hasPendingRequest': instance.hasPendingRequest,
  'userRole': instance.userRole,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'owner': instance.owner,
  'member': instance.member,
  'moderator': instance.moderator,
};
