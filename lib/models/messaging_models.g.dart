// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationResponse _$ConversationResponseFromJson(
  Map<String, dynamic> json,
) => ConversationResponse(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
  title: json['title'] as String?,
  createdById: (json['createdById'] as num).toInt(),
  createdByUsername: json['createdByUsername'] as String,
  createdByDisplayName: json['createdByDisplayName'] as String,
  createdByAvatarUrl: json['createdByAvatarUrl'] as String?,
  memberCount: (json['memberCount'] as num).toInt(),
  unreadCount: (json['unreadCount'] as num).toInt(),
  lastMessage: json['lastMessage'] == null
      ? null
      : MessageResponse.fromJson(json['lastMessage'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isMember: json['member'] as bool? ?? false,
  userRole: $enumDecodeNullable(
    _$ConversationMemberRoleEnumMap,
    json['userRole'],
  ),
  otherParticipantId: (json['otherParticipantId'] as num?)?.toInt(),
  otherParticipantUsername: json['otherParticipantUsername'] as String?,
  otherParticipantDisplayName: json['otherParticipantDisplayName'] as String?,
  otherParticipantAvatarUrl: json['otherParticipantAvatarUrl'] as String?,
  otherParticipantIsOnline: json['otherParticipantIsOnline'] as bool?,
  otherParticipantLastSeenAt: json['otherParticipantLastSeenAt'] == null
      ? null
      : DateTime.parse(json['otherParticipantLastSeenAt'] as String),
  members: (json['members'] as List<dynamic>?)
      ?.map(
        (e) => ConversationMemberResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$ConversationResponseToJson(
  ConversationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$ConversationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'createdById': instance.createdById,
  'createdByUsername': instance.createdByUsername,
  'createdByDisplayName': instance.createdByDisplayName,
  'createdByAvatarUrl': instance.createdByAvatarUrl,
  'memberCount': instance.memberCount,
  'unreadCount': instance.unreadCount,
  'lastMessage': instance.lastMessage?.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'member': instance.isMember,
  'userRole': _$ConversationMemberRoleEnumMap[instance.userRole],
  'otherParticipantId': instance.otherParticipantId,
  'otherParticipantUsername': instance.otherParticipantUsername,
  'otherParticipantDisplayName': instance.otherParticipantDisplayName,
  'otherParticipantAvatarUrl': instance.otherParticipantAvatarUrl,
  'otherParticipantIsOnline': instance.otherParticipantIsOnline,
  'otherParticipantLastSeenAt': instance.otherParticipantLastSeenAt
      ?.toIso8601String(),
  'members': instance.members?.map((e) => e.toJson()).toList(),
};

const _$ConversationTypeEnumMap = {
  ConversationType.direct: 'direct',
  ConversationType.group: 'group',
};

const _$ConversationMemberRoleEnumMap = {
  ConversationMemberRole.member: 'member',
  ConversationMemberRole.admin: 'admin',
};

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversationId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      senderUsername: json['senderUsername'] as String,
      senderDisplayName: json['senderDisplayName'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String,
      messageType: $enumDecode(_$MessageTypeEnumMap, json['messageType']),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map(
            (e) =>
                MessageAttachmentResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      isRead: json['read'] as bool? ?? false,
      isEdited: json['edited'] as bool? ?? false,
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      reactionCounts: (json['reactionCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      currentUserReaction: json['currentUserReaction'] as String?,
      replyTo: json['replyTo'] == null
          ? null
          : ParentMessageInfo.fromJson(json['replyTo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'senderUsername': instance.senderUsername,
      'senderDisplayName': instance.senderDisplayName,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'content': instance.content,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'read': instance.isRead,
      'edited': instance.isEdited,
      'editedAt': instance.editedAt?.toIso8601String(),
      'reactionCounts': instance.reactionCounts,
      'currentUserReaction': instance.currentUserReaction,
      'replyTo': instance.replyTo?.toJson(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.file: 'file',
};

ParentMessageInfo _$ParentMessageInfoFromJson(Map<String, dynamic> json) =>
    ParentMessageInfo(
      id: (json['id'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      senderUsername: json['senderUsername'] as String,
      contentPreview: json['contentPreview'] as String,
      messageType: $enumDecode(_$MessageTypeEnumMap, json['messageType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ParentMessageInfoToJson(ParentMessageInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderUsername': instance.senderUsername,
      'contentPreview': instance.contentPreview,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

MessageAttachmentResponse _$MessageAttachmentResponseFromJson(
  Map<String, dynamic> json,
) => MessageAttachmentResponse(
  id: (json['id'] as num).toInt(),
  fileName: json['fileName'] as String,
  fileUrl: json['fileUrl'] as String,
  fileType: json['fileType'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessageAttachmentResponseToJson(
  MessageAttachmentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fileName': instance.fileName,
  'fileUrl': instance.fileUrl,
  'fileType': instance.fileType,
  'fileSize': instance.fileSize,
  'createdAt': instance.createdAt.toIso8601String(),
};

ConversationMemberResponse _$ConversationMemberResponseFromJson(
  Map<String, dynamic> json,
) => ConversationMemberResponse(
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  role: $enumDecode(_$ConversationMemberRoleEnumMap, json['role']),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  lastReadMessageId: (json['lastReadMessageId'] as num?)?.toInt(),
  isOnline: json['isOnline'] as bool? ?? false,
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
);

Map<String, dynamic> _$ConversationMemberResponseToJson(
  ConversationMemberResponse instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'role': _$ConversationMemberRoleEnumMap[instance.role]!,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'lastReadMessageId': instance.lastReadMessageId,
  'isOnline': instance.isOnline,
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
};

ConversationListResponse _$ConversationListResponseFromJson(
  Map<String, dynamic> json,
) => ConversationListResponse(
  conversations: (json['conversations'] as List<dynamic>)
      .map((e) => ConversationResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasNext: json['hasNext'] as bool? ?? false,
  hasPrevious: json['hasPrevious'] as bool? ?? false,
);

Map<String, dynamic> _$ConversationListResponseToJson(
  ConversationListResponse instance,
) => <String, dynamic>{
  'conversations': instance.conversations.map((e) => e.toJson()).toList(),
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'hasNext': instance.hasNext,
  'hasPrevious': instance.hasPrevious,
};

MessageListResponse _$MessageListResponseFromJson(Map<String, dynamic> json) =>
    MessageListResponse(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['currentPage'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageListResponseToJson(
  MessageListResponse instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'hasNext': instance.hasNext,
  'hasPrevious': instance.hasPrevious,
};

WebSocketMessage _$WebSocketMessageFromJson(Map<String, dynamic> json) =>
    WebSocketMessage(
      type: json['type'] as String,
      data: json['data'],
      conversationId: (json['conversationId'] as num?)?.toInt(),
      senderId: (json['senderId'] as num?)?.toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$WebSocketMessageToJson(WebSocketMessage instance) =>
    <String, dynamic>{
      'type': instance.type,
      'data': instance.data,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'timestamp': instance.timestamp.toIso8601String(),
    };

TypingRequest _$TypingRequestFromJson(Map<String, dynamic> json) =>
    TypingRequest(
      conversationId: (json['conversationId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      isTyping: json['isTyping'] as bool,
    );

Map<String, dynamic> _$TypingRequestToJson(TypingRequest instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'username': instance.username,
      'isTyping': instance.isTyping,
    };

CreateConversationRequest _$CreateConversationRequestFromJson(
  Map<String, dynamic> json,
) => CreateConversationRequest(
  type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
  title: json['title'] as String?,
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$CreateConversationRequestToJson(
  CreateConversationRequest instance,
) => <String, dynamic>{
  'type': _$ConversationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'participantIds': instance.participantIds,
};

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) =>
    SendMessageRequest(
      conversationId: (json['conversationId'] as num).toInt(),
      content: json['content'] as String,
      messageType: $enumDecode(_$MessageTypeEnumMap, json['messageType']),
      attachmentUrls: (json['attachmentUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      replyToMessageId: (json['replyToMessageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'content': instance.content,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'attachmentUrls': instance.attachmentUrls,
      'replyToMessageId': instance.replyToMessageId,
    };

MarkAsReadRequest _$MarkAsReadRequestFromJson(Map<String, dynamic> json) =>
    MarkAsReadRequest(
      conversationId: (json['conversationId'] as num).toInt(),
      messageId: (json['messageId'] as num).toInt(),
    );

Map<String, dynamic> _$MarkAsReadRequestToJson(MarkAsReadRequest instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'messageId': instance.messageId,
    };
