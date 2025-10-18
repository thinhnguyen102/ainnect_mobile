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
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class PostMedia {
  final int id;
  final String mediaUrl;
  final String mediaType;
  final String createdAt;

  const PostMedia({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) => _$PostMediaFromJson(json);
  Map<String, dynamic> toJson() => _$PostMediaToJson(this);
}

@JsonSerializable()
class PostReactions {
  final int totalCount;
  final List<ReactionCount> reactionCounts;
  final List<UserReaction> recentReactions;
  final bool currentUserReacted;
  final String? currentUserReactionType;

  const PostReactions({
    required this.totalCount,
    required this.reactionCounts,
    required this.recentReactions,
    required this.currentUserReacted,
    this.currentUserReactionType,
  });

  factory PostReactions.fromJson(Map<String, dynamic> json) => _$PostReactionsFromJson(json);
  Map<String, dynamic> toJson() => _$PostReactionsToJson(this);
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