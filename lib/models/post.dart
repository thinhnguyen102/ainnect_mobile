import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final int authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final int? groupId;
  final String content;
  final String visibility;
  final int commentCount;
  final int reactionCount;
  final int shareCount;
  final PostReactions reactions;
  final List<PostMedia> media;
  final String createdAt;
  final String updatedAt;
  final ShareInfo? shareInfo;
  final Post? sharedPost;
  
  // Moderation fields
  final String? moderationStatus; // PENDING, APPROVED, REJECTED
  final String? moderationReason;
  final bool? isSensitive;
  final bool? isViolent;
  final String? mood;
  final double? moodScore;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    this.groupId,
    required this.content,
    required this.visibility,
    required this.commentCount,
    required this.reactionCount,
    required this.shareCount,
    required this.reactions,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
    this.shareInfo,
    this.sharedPost,
    this.moderationStatus,
    this.moderationReason,
    this.isSensitive,
    this.isViolent,
    this.mood,
    this.moodScore,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final post = _$PostFromJson(json);
    return Post(
      id: post.id,
      authorId: post.authorId,
      authorUsername: post.authorUsername,
      authorDisplayName: post.authorDisplayName,
      authorAvatarUrl: post.authorAvatarUrl,
      groupId: post.groupId,
      content: post.content,
      visibility: post.visibility,
      commentCount: post.commentCount,
      reactionCount: post.reactionCount,
      shareCount: post.shareCount,
      reactions: post.reactions,
      media: post.media,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      shareInfo: json['shareInfo'] != null 
          ? ShareInfo.fromJson(json['shareInfo'] as Map<String, dynamic>)
          : null,
      sharedPost: json['sharedPost'] != null
          ? Post.fromJson(json['sharedPost'] as Map<String, dynamic>)
          : null,
      moderationStatus: post.moderationStatus,
      moderationReason: post.moderationReason,
      isSensitive: post.isSensitive,
      isViolent: post.isViolent,
      mood: post.mood,
      moodScore: post.moodScore,
    );
  }
  
  Map<String, dynamic> toJson() {
    final data = _$PostToJson(this);
    if (shareInfo != null) {
      data['shareInfo'] = shareInfo!.toJson();
    }
    if (sharedPost != null) {
      data['sharedPost'] = sharedPost!.toJson();
    }
    return data;
  }
  
  Post copyWith({
    int? id,
    int? authorId,
    String? authorUsername,
    String? authorDisplayName,
    String? authorAvatarUrl,
    int? groupId,
    String? content,
    String? visibility,
    int? commentCount,
    int? reactionCount,
    int? shareCount,
    PostReactions? reactions,
    List<PostMedia>? media,
    String? createdAt,
    String? updatedAt,
    ShareInfo? shareInfo,
    Post? sharedPost,
    String? moderationStatus,
    String? moderationReason,
    bool? isSensitive,
    bool? isViolent,
    String? mood,
    double? moodScore,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      visibility: visibility ?? this.visibility,
      commentCount: commentCount ?? this.commentCount,
      reactionCount: reactionCount ?? this.reactionCount,
      shareCount: shareCount ?? this.shareCount,
      reactions: reactions ?? this.reactions,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shareInfo: shareInfo ?? this.shareInfo,
      sharedPost: sharedPost ?? this.sharedPost,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationReason: moderationReason ?? this.moderationReason,
      isSensitive: isSensitive ?? this.isSensitive,
      isViolent: isViolent ?? this.isViolent,
      mood: mood ?? this.mood,
      moodScore: moodScore ?? this.moodScore,
    );
  }
  
  bool get isShared => shareInfo != null;
  Post get originalPost => sharedPost ?? this;
}

@JsonSerializable()
class PostMedia {
  final int id;
  final String? mediaUrl;
  final String? mediaType;
  final String? createdAt;

  const PostMedia({
    required this.id,
    this.mediaUrl,
    this.mediaType,
    this.createdAt,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) => _$PostMediaFromJson(json);
  Map<String, dynamic> toJson() => _$PostMediaToJson(this);
}

@JsonSerializable()
class PostReactions {
  int totalCount;
  List<ReactionCount> reactionCounts;
  List<UserReaction> recentReactions;
  bool currentUserReacted;
  String? currentUserReactionType;

  PostReactions({
    required this.totalCount,
    required this.reactionCounts,
    required this.recentReactions,
    required this.currentUserReacted,
    this.currentUserReactionType,
  });

  factory PostReactions.fromJson(Map<String, dynamic> json) => _$PostReactionsFromJson(json);
  Map<String, dynamic> toJson() => _$PostReactionsToJson(this);
  
  PostReactions copyWith({
    int? totalCount,
    List<ReactionCount>? reactionCounts,
    List<UserReaction>? recentReactions,
    bool? currentUserReacted,
    String? currentUserReactionType,
  }) {
    return PostReactions(
      totalCount: totalCount ?? this.totalCount,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      recentReactions: recentReactions ?? this.recentReactions,
      currentUserReacted: currentUserReacted ?? this.currentUserReacted,
      currentUserReactionType: currentUserReactionType ?? this.currentUserReactionType,
    );
  }
}

@JsonSerializable()
class ReactionCount {
  final String type;
  final int count;

  const ReactionCount({
    required this.type,
    required this.count,
  });

  factory ReactionCount.fromJson(Map<String, dynamic> json) => _$ReactionCountFromJson(json);
  Map<String, dynamic> toJson() => _$ReactionCountToJson(this);
}

@JsonSerializable()
class UserReaction {
  final int id;
  final String type;
  final int userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String createdAt;

  const UserReaction({
    required this.id,
    required this.type,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserReaction.fromJson(Map<String, dynamic> json) => _$UserReactionFromJson(json);
  Map<String, dynamic> toJson() => _$UserReactionToJson(this);
}

class ShareInfo {
  final int shareId;
  final int sharedByUserId;
  final String sharedByUsername;
  final String sharedByDisplayName;
  final String? sharedByAvatarUrl;
  final String? shareComment;
  final String sharedAt;

  const ShareInfo({
    required this.shareId,
    required this.sharedByUserId,
    required this.sharedByUsername,
    required this.sharedByDisplayName,
    this.sharedByAvatarUrl,
    this.shareComment,
    required this.sharedAt,
  });

  factory ShareInfo.fromJson(Map<String, dynamic> json) {
    return ShareInfo(
      shareId: (json['shareId'] as num).toInt(),
      sharedByUserId: (json['sharedByUserId'] as num).toInt(),
      sharedByUsername: json['sharedByUsername'] as String,
      sharedByDisplayName: json['sharedByDisplayName'] as String,
      sharedByAvatarUrl: json['sharedByAvatarUrl'] as String?,
      shareComment: json['shareComment'] as String?,
      sharedAt: json['sharedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareId': shareId,
      'sharedByUserId': sharedByUserId,
      'sharedByUsername': sharedByUsername,
      'sharedByDisplayName': sharedByDisplayName,
      'sharedByAvatarUrl': sharedByAvatarUrl,
      'shareComment': shareComment,
      'sharedAt': sharedAt,
    };
  }
}