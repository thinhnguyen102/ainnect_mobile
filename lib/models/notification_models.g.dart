// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBasicInfo _$UserBasicInfoFromJson(Map<String, dynamic> json) =>
    UserBasicInfo(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UserBasicInfoToJson(UserBasicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'avatar': instance.avatar,
      'email': instance.email,
    };

NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => NotificationResponse(
  id: (json['id'] as num).toInt(),
  recipient: UserBasicInfo.fromJson(json['recipient'] as Map<String, dynamic>),
  actor: json['actor'] == null
      ? null
      : UserBasicInfo.fromJson(json['actor'] as Map<String, dynamic>),
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  targetType: json['targetType'] as String?,
  targetId: (json['targetId'] as num?)?.toInt(),
  message: json['message'] as String,
  isRead: json['isRead'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
);

Map<String, dynamic> _$NotificationResponseToJson(
  NotificationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipient': instance.recipient.toJson(),
  'actor': instance.actor?.toJson(),
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'targetType': instance.targetType,
  'targetId': instance.targetId,
  'message': instance.message,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
  'readAt': instance.readAt?.toIso8601String(),
};

const _$NotificationTypeEnumMap = {
  NotificationType.like: 'LIKE',
  NotificationType.comment: 'COMMENT',
  NotificationType.reply: 'REPLY',
  NotificationType.follow: 'FOLLOW',
  NotificationType.unfollow: 'UNFOLLOW',
  NotificationType.friendRequest: 'FRIEND_REQUEST',
  NotificationType.friendAccept: 'FRIEND_ACCEPT',
  NotificationType.mention: 'MENTION',
  NotificationType.share: 'SHARE',
  NotificationType.message: 'MESSAGE',
  NotificationType.groupInvite: 'GROUP_INVITE',
  NotificationType.groupJoin: 'GROUP_JOIN',
  NotificationType.system: 'SYSTEM',
  NotificationType.postModeration: 'POST_MODERATION',
};

NotificationStatsDto _$NotificationStatsDtoFromJson(
  Map<String, dynamic> json,
) => NotificationStatsDto(
  totalCount: (json['totalCount'] as num).toInt(),
  unreadCount: (json['unreadCount'] as num).toInt(),
  todayCount: (json['todayCount'] as num).toInt(),
);

Map<String, dynamic> _$NotificationStatsDtoToJson(
  NotificationStatsDto instance,
) => <String, dynamic>{
  'totalCount': instance.totalCount,
  'unreadCount': instance.unreadCount,
  'todayCount': instance.todayCount,
};
