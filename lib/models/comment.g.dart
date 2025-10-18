// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num).toInt(),
  postId: (json['postId'] as num).toInt(),
  authorId: (json['authorId'] as num).toInt(),
  authorUsername: json['authorUsername'] as String,
  authorDisplayName: json['authorDisplayName'] as String,
  authorAvatarUrl: json['authorAvatarUrl'] as String?,
  parentId: (json['parentId'] as num?)?.toInt(),
  content: json['content'] as String,
  reactionCount: (json['reactionCount'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'authorId': instance.authorId,
  'authorUsername': instance.authorUsername,
  'authorDisplayName': instance.authorDisplayName,
  'authorAvatarUrl': instance.authorAvatarUrl,
  'parentId': instance.parentId,
  'content': instance.content,
  'reactionCount': instance.reactionCount,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

CommentResponse _$CommentResponseFromJson(Map<String, dynamic> json) =>
    CommentResponse(
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['currentPage'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );

Map<String, dynamic> _$CommentResponseToJson(CommentResponse instance) =>
    <String, dynamic>{
      'comments': instance.comments,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrevious': instance.hasPrevious,
    };
