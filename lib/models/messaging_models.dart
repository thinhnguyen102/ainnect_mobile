import 'package:json_annotation/json_annotation.dart';

part 'messaging_models.g.dart';

enum ConversationType {
  @JsonValue('direct')
  direct,
  @JsonValue('group')
  group,
}

enum ConversationMemberRole {
  @JsonValue('member')
  member,
  @JsonValue('admin')
  admin,
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('file')
  file,
}

enum ReactionType {
  @JsonValue('like')
  like,
  @JsonValue('love')
  love,
  @JsonValue('haha')
  haha,
  @JsonValue('wow')
  wow,
  @JsonValue('sad')
  sad,
  @JsonValue('angry')
  angry,
}

@JsonSerializable(explicitToJson: true)
class ConversationResponse {
  final int id;
  final ConversationType type;
  final String? title;
  final int createdById;
  final String createdByUsername;
  final String createdByDisplayName;
  final String? createdByAvatarUrl;
  final int memberCount;
  final int unreadCount;
  final MessageResponse? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(name: 'member', defaultValue: false)
  final bool isMember;
  final ConversationMemberRole? userRole;
  
  // For direct conversations
  final int? otherParticipantId;
  final String? otherParticipantUsername;
  final String? otherParticipantDisplayName;
  final String? otherParticipantAvatarUrl;
  final bool? otherParticipantIsOnline;
  final DateTime? otherParticipantLastSeenAt;
  
  // For group conversations
  final List<ConversationMemberResponse>? members;

  ConversationResponse({
    required this.id,
    required this.type,
    this.title,
    required this.createdById,
    required this.createdByUsername,
    required this.createdByDisplayName,
    this.createdByAvatarUrl,
    required this.memberCount,
    required this.unreadCount,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.isMember,
    this.userRole,
    this.otherParticipantId,
    this.otherParticipantUsername,
    this.otherParticipantDisplayName,
    this.otherParticipantAvatarUrl,
    this.otherParticipantIsOnline,
    this.otherParticipantLastSeenAt,
    this.members,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
  
  String get displayTitle {
    if (type == ConversationType.group) {
      return title ?? 'Group Chat';
    }
    return otherParticipantDisplayName ?? otherParticipantUsername ?? 'Unknown';
  }
  
  String? get displayAvatar {
    if (type == ConversationType.direct) {
      return otherParticipantAvatarUrl;
    }
    return null;
  }
}

@JsonSerializable(explicitToJson: true)
class MessageResponse {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderUsername;
  final String senderDisplayName;
  final String? senderAvatarUrl;
  final String content;
  final MessageType messageType;
  final List<MessageAttachmentResponse>? attachments;
  final DateTime createdAt;
  final DateTime? deletedAt;
  @JsonKey(name: 'read', defaultValue: false)
  final bool isRead;
  @JsonKey(name: 'edited', defaultValue: false)
  final bool isEdited;
  final DateTime? editedAt;
  final Map<String, int>? reactionCounts;
  final String? currentUserReaction;
  final ParentMessageInfo? replyTo;

  MessageResponse({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderUsername,
    required this.senderDisplayName,
    this.senderAvatarUrl,
    required this.content,
    required this.messageType,
    this.attachments,
    required this.createdAt,
    this.deletedAt,
    required this.isRead,
    required this.isEdited,
    this.editedAt,
    this.reactionCounts,
    this.currentUserReaction,
    this.replyTo,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ParentMessageInfo {
  final int id;
  final int senderId;
  final String senderUsername;
  final String contentPreview;
  final MessageType messageType;
  final DateTime createdAt;

  ParentMessageInfo({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.contentPreview,
    required this.messageType,
    required this.createdAt,
  });

  factory ParentMessageInfo.fromJson(Map<String, dynamic> json) =>
      _$ParentMessageInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$ParentMessageInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MessageAttachmentResponse {
  final int id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;

  MessageAttachmentResponse({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
  });

  factory MessageAttachmentResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MessageAttachmentResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConversationMemberResponse {
  final int userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final ConversationMemberRole role;
  final DateTime joinedAt;
  final int? lastReadMessageId;
  @JsonKey(defaultValue: false)
  final bool isOnline;
  final DateTime? lastSeenAt;

  ConversationMemberResponse({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.lastReadMessageId,
    required this.isOnline,
    this.lastSeenAt,
  });

  factory ConversationMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ConversationMemberResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConversationListResponse {
  final List<ConversationResponse> conversations;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  @JsonKey(defaultValue: false)
  final bool hasNext;
  @JsonKey(defaultValue: false)
  final bool hasPrevious;

  ConversationListResponse({
    required this.conversations,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationListResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ConversationListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MessageListResponse {
  final List<MessageResponse> messages;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  @JsonKey(defaultValue: false)
  final bool hasNext;
  @JsonKey(defaultValue: false)
  final bool hasPrevious;

  MessageListResponse({
    required this.messages,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory MessageListResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageListResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MessageListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WebSocketMessage {
  final String type;
  final dynamic data;
  final int? conversationId;
  final int? senderId;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.data,
    this.conversationId,
    this.senderId,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) =>
      _$WebSocketMessageFromJson(json);
  
  Map<String, dynamic> toJson() => _$WebSocketMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TypingRequest {
  final int conversationId;
  final int userId;
  final String username;
  final bool isTyping;

  TypingRequest({
    required this.conversationId,
    required this.userId,
    required this.username,
    required this.isTyping,
  });

  factory TypingRequest.fromJson(Map<String, dynamic> json) =>
      _$TypingRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$TypingRequestToJson(this);
}

// Request DTOs
@JsonSerializable(explicitToJson: true)
class CreateConversationRequest {
  final ConversationType type;
  final String? title;
  final List<int> participantIds;

  CreateConversationRequest({
    required this.type,
    this.title,
    required this.participantIds,
  });

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SendMessageRequest {
  final int conversationId;
  final String content;
  final MessageType messageType;
  final List<String>? attachmentUrls;
  final int? replyToMessageId;

  SendMessageRequest({
    required this.conversationId,
    required this.content,
    required this.messageType,
    this.attachmentUrls,
    this.replyToMessageId,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MarkAsReadRequest {
  final int conversationId;
  final int messageId;

  MarkAsReadRequest({
    required this.conversationId,
    required this.messageId,
  });

  factory MarkAsReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkAsReadRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$MarkAsReadRequestToJson(this);
}
