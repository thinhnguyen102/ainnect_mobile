// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendshipResponse _$FriendshipResponseFromJson(Map<String, dynamic> json) =>
    FriendshipResponse(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
      requestedById: (json['requestedById'] as num).toInt(),
      requestedByUsername: json['requestedByUsername'] as String,
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FriendshipResponseToJson(FriendshipResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
      'requestedById': instance.requestedById,
      'requestedByUsername': instance.requestedByUsername,
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.rejected: 'rejected',
  FriendshipStatus.blocked: 'blocked',
};

FriendRequestRequest _$FriendRequestRequestFromJson(
  Map<String, dynamic> json,
) => FriendRequestRequest(otherUserId: (json['otherUserId'] as num).toInt());

Map<String, dynamic> _$FriendRequestRequestToJson(
  FriendRequestRequest instance,
) => <String, dynamic>{'otherUserId': instance.otherUserId};

FriendRequestListResponse _$FriendRequestListResponseFromJson(
  Map<String, dynamic> json,
) => FriendRequestListResponse(
  friendships: (json['friendships'] as List<dynamic>)
      .map((e) => FriendshipResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasNext: json['hasNext'] as bool,
  hasPrevious: json['hasPrevious'] as bool,
);

Map<String, dynamic> _$FriendRequestListResponseToJson(
  FriendRequestListResponse instance,
) => <String, dynamic>{
  'friendships': instance.friendships.map((e) => e.toJson()).toList(),
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'hasNext': instance.hasNext,
  'hasPrevious': instance.hasPrevious,
};
