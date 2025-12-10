// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostRequest _$CreatePostRequestFromJson(Map<String, dynamic> json) =>
    CreatePostRequest(
      content: json['content'] as String,
      visibility: json['visibility'] as String? ?? 'public_',
      groupId: (json['groupId'] as num?)?.toInt(),
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CreatePostRequestToJson(CreatePostRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
      'visibility': instance.visibility,
      'groupId': instance.groupId,
      'mediaUrls': instance.mediaUrls,
    };
