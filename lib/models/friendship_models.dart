import 'package:json_annotation/json_annotation.dart';

part 'friendship_models.g.dart';

enum FriendshipStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('blocked')
  blocked,
}

// Simple user model for friend lists
class FriendUser {
  final int userId;
  final String username;
  final String displayName;
  final String? avatarUrl;

  FriendUser({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      userId: json['userId'] as int,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

// Social stats model
class SocialStats {
  final int userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final int sharesCount;
  final bool canSendFriendRequest;
  final bool following;
  final bool friend;
  final bool blocked;

  SocialStats({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.sharesCount,
    required this.canSendFriendRequest,
    required this.following,
    required this.friend,
    required this.blocked,
  });

  factory SocialStats.fromJson(Map<String, dynamic> json) {
    return SocialStats(
      userId: json['userId'] as int,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      followersCount: json['followersCount'] as int,
      followingCount: json['followingCount'] as int,
      friendsCount: json['friendsCount'] as int,
      sharesCount: json['sharesCount'] as int,
      canSendFriendRequest: json['canSendFriendRequest'] as bool,
      following: json['following'] as bool,
      friend: json['friend'] as bool,
      blocked: json['blocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'friendsCount': friendsCount,
      'sharesCount': sharesCount,
      'canSendFriendRequest': canSendFriendRequest,
      'following': following,
      'friend': friend,
      'blocked': blocked,
    };
  }
}

@JsonSerializable(explicitToJson: true)
class FriendshipResponse {
  final int userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final FriendshipStatus status;
  final int requestedById;
  final String requestedByUsername;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  FriendshipResponse({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.status,
    required this.requestedById,
    required this.requestedByUsername,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendshipResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendshipResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipResponseToJson(this);
  
  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isRejected => status == FriendshipStatus.rejected;
}

@JsonSerializable()
class FriendRequestRequest {
  final int otherUserId;

  FriendRequestRequest({
    required this.otherUserId,
  });

  factory FriendRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FriendRequestListResponse {
  final List<FriendshipResponse> friendships;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  FriendRequestListResponse({
    required this.friendships,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory FriendRequestListResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestListResponseToJson(this);
}
