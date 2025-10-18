// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: (json['id'] as num).toInt(),
  authorId: (json['authorId'] as num).toInt(),
  authorUsername: json['authorUsername'] as String,
  authorDisplayName: json['authorDisplayName'] as String,
  authorAvatarUrl: json['authorAvatarUrl'] as String?,
  groupId: (json['groupId'] as num?)?.toInt(),
  content: json['content'] as String,
  visibility: json['visibility'] as String,
  commentCount: (json['commentCount'] as num).toInt(),
  reactionCount: (json['reactionCount'] as num).toInt(),
  shareCount: (json['shareCount'] as num).toInt(),
  reactions: PostReactions.fromJson(json['reactions'] as Map<String, dynamic>),
  media: (json['media'] as List<dynamic>)
      .map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'authorId': instance.authorId,
  'authorUsername': instance.authorUsername,
  'authorDisplayName': instance.authorDisplayName,
  'authorAvatarUrl': instance.authorAvatarUrl,
  'groupId': instance.groupId,
  'content': instance.content,
  'visibility': instance.visibility,
  'commentCount': instance.commentCount,
  'reactionCount': instance.reactionCount,
  'shareCount': instance.shareCount,
  'reactions': instance.reactions,
  'media': instance.media,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

PostMedia _$PostMediaFromJson(Map<String, dynamic> json) => PostMedia(
  id: (json['id'] as num).toInt(),
  mediaUrl: json['mediaUrl'] as String,
  mediaType: json['mediaType'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$PostMediaToJson(PostMedia instance) => <String, dynamic>{
  'id': instance.id,
  'mediaUrl': instance.mediaUrl,
  'mediaType': instance.mediaType,
  'createdAt': instance.createdAt,
};

PostReactions _$PostReactionsFromJson(Map<String, dynamic> json) =>
    PostReactions(
      totalCount: (json['totalCount'] as num).toInt(),
      reactionCounts: (json['reactionCounts'] as List<dynamic>)
          .map((e) => ReactionCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentReactions: (json['recentReactions'] as List<dynamic>)
          .map((e) => UserReaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentUserReacted: json['currentUserReacted'] as bool,
      currentUserReactionType: json['currentUserReactionType'] as String?,
    );

Map<String, dynamic> _$PostReactionsToJson(PostReactions instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'reactionCounts': instance.reactionCounts,
      'recentReactions': instance.recentReactions,
      'currentUserReacted': instance.currentUserReacted,
      'currentUserReactionType': instance.currentUserReactionType,
    };

ReactionCount _$ReactionCountFromJson(Map<String, dynamic> json) =>
    ReactionCount(
      type: json['type'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ReactionCountToJson(ReactionCount instance) =>
    <String, dynamic>{'type': instance.type, 'count': instance.count};

UserReaction _$UserReactionFromJson(Map<String, dynamic> json) => UserReaction(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$UserReactionToJson(UserReaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt,
    };
