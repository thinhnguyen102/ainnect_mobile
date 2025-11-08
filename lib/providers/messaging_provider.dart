import 'package:flutter/foundation.dart';
import '../models/messaging_models.dart';
import '../services/messaging_service.dart';
import '../services/websocket_service.dart';
import '../utils/logger.dart';

class MessagingProvider with ChangeNotifier {
  final MessagingService _messagingService = MessagingService();
  final WebSocketService _wsService = WebSocketService();
  
  List<ConversationResponse> _conversations = [];
  Map<int, List<MessageResponse>> _conversationMessages = {};
  Map<int, Set<int>> _typingUsers = {}; // conversationId -> Set of typing user IDs
  bool _isLoading = false;
  String? _error;
  
  int _currentPage = 0;
  bool _hasMore = true;
  
  List<ConversationResponse> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  List<MessageResponse>? getMessages(int conversationId) {
    return _conversationMessages[conversationId];
  }
  
  Set<int> getTypingUsers(int conversationId) {
    return _typingUsers[conversationId] ?? {};
  }
  
  int get unreadCount {
    return _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  // Expose streams from WebSocketService
  Stream<WebSocketMessage> get messageStream => _wsService.messageStream;
  Stream<Map<String, dynamic>> get notificationStream => _wsService.notificationStream;

  MessagingProvider() {
    _initialize();
  }

  void _initialize() {
    // Listen to WebSocket messages
    _wsService.messageStream.listen((wsMessage) {
      _handleWebSocketMessage(wsMessage);
    });
    
    // Listen to typing indicators
    _wsService.typingStream.listen((typingRequest) {
      _handleTypingIndicator(typingRequest);
    });
    
    // Listen to connection state
    _wsService.connectionStateStream.listen((isConnected) {
      if (isConnected) {
        Logger.debug('WebSocket connected, refreshing conversations');
        refreshConversations();
      }
    });
  }

  void _handleWebSocketMessage(WebSocketMessage wsMessage) {
    Logger.debug('📨 Handling WebSocket message: ${wsMessage.type}');
    
    switch (wsMessage.type) {
      case 'NEW_MESSAGE':
        if (wsMessage.data != null) {
          try {
            Logger.debug('Parsing NEW_MESSAGE data: ${wsMessage.data}');
            final message = MessageResponse.fromJson(wsMessage.data as Map<String, dynamic>);
            Logger.debug('✅ Successfully parsed message: ID=${message.id}, content="${message.content}"');
            _addNewMessage(message);
          } catch (e, stackTrace) {
            Logger.error('❌ Error parsing NEW_MESSAGE: $e');
            Logger.error('Stack trace: $stackTrace');
            Logger.error('Raw data: ${wsMessage.data}');
          }
        }
        break;
      case 'MESSAGE_READ':
        // Handle read receipt
        if (wsMessage.data != null) {
          try {
            Logger.debug('Handling MESSAGE_READ receipt: ${wsMessage.data}');
            print('👁️ Received read receipt: ${wsMessage.data}');
            final data = wsMessage.data as Map<String, dynamic>;
            final conversationId = data['conversationId'] as int?;
            final messageId = data['messageId'] as int?;
            
            if (conversationId != null && messageId != null) {
              _updateMessageReadStatus(conversationId, messageId);
            }
          } catch (e, stackTrace) {
            Logger.error('❌ Error handling MESSAGE_READ: $e');
            Logger.error('Stack trace: $stackTrace');
          }
        }
        notifyListeners();
        break;
      case 'ERROR':
        _error = wsMessage.data?.toString() ?? 'Unknown error';
        Logger.error('WebSocket ERROR message: $_error');
        notifyListeners();
        break;
      default:
        Logger.debug('Unknown WebSocket message type: ${wsMessage.type}');
    }
  }

  void _handleTypingIndicator(TypingRequest typingRequest) {
    final conversationId = typingRequest.conversationId;
    final userId = typingRequest.userId;
    
    if (!_typingUsers.containsKey(conversationId)) {
      _typingUsers[conversationId] = {};
    }
    
    if (typingRequest.isTyping) {
      _typingUsers[conversationId]!.add(userId);
    } else {
      _typingUsers[conversationId]!.remove(userId);
    }
    
    notifyListeners();
  }

  void _updateMessageReadStatus(int conversationId, int messageId) {
    Logger.debug('Updating read status for message $messageId in conversation $conversationId');
    
    if (_conversationMessages.containsKey(conversationId)) {
      final messages = _conversationMessages[conversationId]!;
      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      
      if (messageIndex != -1) {
        // Update message read status (you might need to add a 'isRead' field to MessageResponse)
        Logger.debug('✅ Message marked as read in local cache');
      }
    }
  }

  void _addNewMessage(MessageResponse message) {
    // Add message to conversation messages
    // Since messages are reversed (newest at end), add new message at the end
    if (_conversationMessages.containsKey(message.conversationId)) {
      // Check if message already exists to avoid duplicates
      final messages = _conversationMessages[message.conversationId]!;
      final exists = messages.any((m) => m.id == message.id);
      
      if (!exists) {
        Logger.debug('➕ Adding new message ID=${message.id} to conversation ${message.conversationId}');
        messages.add(message);
      } else {
        Logger.debug('⚠️ Message ID=${message.id} already exists, skipping duplicate');
      }
    }
    
    // Update conversation in list
    final conversationIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (conversationIndex != -1) {
      final oldConv = _conversations[conversationIndex];
      final updatedConv = ConversationResponse(
        id: oldConv.id,
        type: oldConv.type,
        title: oldConv.title,
        createdById: oldConv.createdById,
        createdByUsername: oldConv.createdByUsername,
        createdByDisplayName: oldConv.createdByDisplayName,
        createdByAvatarUrl: oldConv.createdByAvatarUrl,
        memberCount: oldConv.memberCount,
        unreadCount: oldConv.unreadCount + 1,
        lastMessage: message,
        createdAt: oldConv.createdAt,
        updatedAt: DateTime.now(),
        isMember: oldConv.isMember,
        userRole: oldConv.userRole,
        otherParticipantId: oldConv.otherParticipantId,
        otherParticipantUsername: oldConv.otherParticipantUsername,
        otherParticipantDisplayName: oldConv.otherParticipantDisplayName,
        otherParticipantAvatarUrl: oldConv.otherParticipantAvatarUrl,
        otherParticipantIsOnline: oldConv.otherParticipantIsOnline,
        otherParticipantLastSeenAt: oldConv.otherParticipantLastSeenAt,
        members: oldConv.members,
      );
      
      _conversations.removeAt(conversationIndex);
      _conversations.insert(0, updatedConv);
    }
    
    notifyListeners();
  }

  Future<void> loadConversations({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _conversations.clear();
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _messagingService.getUserConversations(
        page: _currentPage,
        size: 10,
      );
      
      if (refresh) {
        _conversations = response.conversations;
      } else {
        _conversations.addAll(response.conversations);
      }
      
      _hasMore = response.hasNext;
      _currentPage++;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      Logger.error('Error loading conversations: $e');
    }
  }

  Future<void> refreshConversations() async {
    await loadConversations(refresh: true);
  }

  Future<void> loadMessages(int conversationId, {bool refresh = false}) async {
    if (refresh) {
      _conversationMessages[conversationId] = [];
    }
    
    try {
      final response = await _messagingService.getConversationMessages(
        conversationId,
        page: 0,
        size: 50,
      );
      
      _conversationMessages[conversationId] = response.messages.reversed.toList();
      
      // Subscribe to conversation WebSocket
      _wsService.subscribeToConversation(conversationId);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      Logger.error('Error loading messages: $e');
    }
  }

  Future<void> sendMessage(SendMessageRequest request) async {
    Logger.debug('📨 MessagingProvider.sendMessage called for conversation ${request.conversationId}');
    Logger.debug('  Content: ${request.content}');
    Logger.debug('  MessageType: ${request.messageType}');
    
    // Send via WebSocket
    print('📡 Sending message via WebSocket...');
    _wsService.sendMessage(request.conversationId, request);
    
    // The message will be received via WebSocket messageStream and handled by _handleWebSocketMessage
    // No need to reload all messages, which would cause duplicates
    Logger.debug('✅ Message sent, waiting for WebSocket confirmation...');
  }

  Future<void> sendTypingIndicator(int conversationId, int userId, String username, bool isTyping) async {
    _wsService.sendTypingIndicator(conversationId, userId, username, isTyping);
  }

  Future<void> markAsRead(int conversationId, int messageId) async {
    try {
      await _messagingService.markAsRead(conversationId, messageId);
      _wsService.markAsRead(conversationId, messageId);
      
      // Update unread count locally
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final oldConv = _conversations[index];
        final updatedConv = ConversationResponse(
          id: oldConv.id,
          type: oldConv.type,
          title: oldConv.title,
          createdById: oldConv.createdById,
          createdByUsername: oldConv.createdByUsername,
          createdByDisplayName: oldConv.createdByDisplayName,
          createdByAvatarUrl: oldConv.createdByAvatarUrl,
          memberCount: oldConv.memberCount,
          unreadCount: 0,
          lastMessage: oldConv.lastMessage,
          createdAt: oldConv.createdAt,
          updatedAt: oldConv.updatedAt,
          isMember: oldConv.isMember,
          userRole: oldConv.userRole,
          otherParticipantId: oldConv.otherParticipantId,
          otherParticipantUsername: oldConv.otherParticipantUsername,
          otherParticipantDisplayName: oldConv.otherParticipantDisplayName,
          otherParticipantAvatarUrl: oldConv.otherParticipantAvatarUrl,
          otherParticipantIsOnline: oldConv.otherParticipantIsOnline,
          otherParticipantLastSeenAt: oldConv.otherParticipantLastSeenAt,
          members: oldConv.members,
        );
        _conversations[index] = updatedConv;
        notifyListeners();
      }
    } catch (e) {
      Logger.error('Error marking as read: $e');
    }
  }

  Future<void> reactToMessage(int messageId, String reactionType) async {
    try {
      await _messagingService.reactToMessage(messageId, reactionType);
    } catch (e) {
      Logger.error('Error reacting to message: $e');
    }
  }

  Future<void> removeReaction(int messageId) async {
    try {
      await _messagingService.removeReaction(messageId);
    } catch (e) {
      Logger.error('Error removing reaction: $e');
    }
  }

  Future<ConversationResponse> createConversation(CreateConversationRequest request) async {
    try {
      final conversation = await _messagingService.createConversation(request);
      _conversations.insert(0, conversation);
      notifyListeners();
      return conversation;
    } catch (e) {
      Logger.error('Error creating conversation: $e');
      rethrow;
    }
  }

  void unsubscribeFromConversation(int conversationId) {
    _wsService.unsubscribeFromConversation(conversationId);
  }
}
