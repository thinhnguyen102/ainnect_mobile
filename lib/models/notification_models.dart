import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

enum NotificationType {
  @JsonValue('LIKE')
  like,
  @JsonValue('COMMENT')
  comment,
  @JsonValue('REPLY')
  reply,
  @JsonValue('FOLLOW')
  follow,
  @JsonValue('UNFOLLOW')
  unfollow,
  @JsonValue('FRIEND_REQUEST')
  friendRequest,
  @JsonValue('FRIEND_ACCEPT')
  friendAccept,
  @JsonValue('MENTION')
  mention,
  @JsonValue('SHARE')
  share,
  @JsonValue('MESSAGE')
  message,
  @JsonValue('GROUP_INVITE')
  groupInvite,
  @JsonValue('GROUP_JOIN')
  groupJoin,
  @JsonValue('SYSTEM')
  system,
}

@JsonSerializable(explicitToJson: true)
class UserBasicInfo {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? email;

  UserBasicInfo({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatar,
    this.email,
  });

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$UserBasicInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserBasicInfoToJson(this);
  
  // Helper getter for display name
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }
  
  // Helper getter for avatar URL
  String? get avatarUrl => avatar;
}

@JsonSerializable(explicitToJson: true)
class NotificationResponse {
  final int id;
  final UserBasicInfo recipient;
  final UserBasicInfo? actor;
  final NotificationType type;
  final String? targetType;
  final int? targetId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationResponse({
    required this.id,
    required this.recipient,
    this.actor,
    required this.type,
    this.targetType,
    this.targetId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
  
  String get typeDisplayName {
    switch (type) {
      case NotificationType.like:
        return 'Thích';
      case NotificationType.comment:
        return 'Bình luận';
      case NotificationType.reply:
        return 'Trả lời';
      case NotificationType.follow:
        return 'Theo dõi';
      case NotificationType.unfollow:
        return 'Hủy theo dõi';
      case NotificationType.friendRequest:
        return 'Lời mời kết bạn';
      case NotificationType.friendAccept:
        return 'Chấp nhận kết bạn';
      case NotificationType.mention:
        return 'Nhắc đến';
      case NotificationType.share:
        return 'Chia sẻ';
      case NotificationType.message:
        return 'Tin nhắn';
      case NotificationType.groupInvite:
        return 'Lời mời nhóm';
      case NotificationType.groupJoin:
        return 'Tham gia nhóm';
      case NotificationType.system:
        return 'Hệ thống';
    }
  }
}

@JsonSerializable(explicitToJson: true)
class NotificationStatsDto {
  final int totalCount;
  final int unreadCount;
  final int todayCount;

  NotificationStatsDto({
    required this.totalCount,
    required this.unreadCount,
    required this.todayCount,
  });

  factory NotificationStatsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationStatsDtoToJson(this);
}
