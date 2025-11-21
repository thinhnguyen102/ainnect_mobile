import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'privacy')
  final String visibility;
  final String? avatarUrl;
  @JsonKey(name: 'coverUrl')
  final String? coverImageUrl;
  final bool requiresApproval; 
  
  final int ownerId;
  final String ownerUsername;
  final String ownerDisplayName;
  final int memberCount;
  final bool hasPendingRequest;
  final String userRole;
  final String createdAt;
  final String updatedAt;
  final bool owner;
  final bool member;
  final bool moderator;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.visibility,
    this.avatarUrl,
    this.coverImageUrl,
    required this.requiresApproval,
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerDisplayName,
    required this.memberCount,
    required this.hasPendingRequest,
    required this.userRole,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
    required this.member,
    required this.moderator,
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}


