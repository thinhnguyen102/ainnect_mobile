import 'package:json_annotation/json_annotation.dart';

part 'reaction.g.dart';

enum ReactionType {
  @JsonValue('LIKE')
  like,
  @JsonValue('LOVE')
  love,
  @JsonValue('HAHA')
  haha,
  @JsonValue('WOW')
  wow,
  @JsonValue('SAD')
  sad,
  @JsonValue('ANGRY')
  angry,
}

@JsonSerializable()
class Reaction {
  final int id;
  final int postId;
  final int userId;
  final ReactionType reactionType;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  const Reaction({
    required this.id,
    required this.postId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => _$ReactionFromJson(json);
  Map<String, dynamic> toJson() => _$ReactionToJson(this);
}
