// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reaction _$ReactionFromJson(Map<String, dynamic> json) => Reaction(
  id: (json['id'] as num).toInt(),
  postId: (json['postId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  reactionType: $enumDecode(_$ReactionTypeEnumMap, json['reactionType']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  userName: json['userName'] as String?,
  userAvatar: json['userAvatar'] as String?,
);

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'userId': instance.userId,
  'reactionType': _$ReactionTypeEnumMap[instance.reactionType]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'userName': instance.userName,
  'userAvatar': instance.userAvatar,
};

const _$ReactionTypeEnumMap = {
  ReactionType.like: 'LIKE',
  ReactionType.love: 'LOVE',
  ReactionType.haha: 'HAHA',
  ReactionType.wow: 'WOW',
  ReactionType.sad: 'SAD',
  ReactionType.angry: 'ANGRY',
};
