import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final int postId;
  final int authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final int? parentId;
  final String content;
  final int reactionCount;
  final int? replyCount;
  final bool? hasChild;
  final bool? currentUserReacted;
  final String? currentUserReactionType;
  final String createdAt;
  final String updatedAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    this.parentId,
    required this.content,
    required this.reactionCount,
    this.replyCount,
    this.hasChild,
    this.currentUserReacted,
    this.currentUserReactionType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class CommentResponse {
  final List<Comment> comments;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const CommentResponse({
    required this.comments,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) => _$CommentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommentResponseToJson(this);
}