import 'package:json_annotation/json_annotation.dart';

part 'create_post_request.g.dart';

@JsonSerializable()
class CreatePostRequest {
  final String content;
  final String visibility;
  final int? groupId;
  final List<String> mediaUrls;

  CreatePostRequest({
    required this.content,
    this.visibility = 'public_',
    this.groupId,
    this.mediaUrls = const [],
  });

  factory CreatePostRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostRequestToJson(this);
}
