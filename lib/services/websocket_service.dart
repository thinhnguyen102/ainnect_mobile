import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/messaging_models.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _stompClient;
  bool _isConnected = false;
  String? _authToken;
  
  final _messageStreamController = StreamController<WebSocketMessage>.broadcast();
  final _typingStreamController = StreamController<TypingRequest>.broadcast();
  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();
  
  Stream<WebSocketMessage> get messageStream => _messageStreamController.stream;
  Stream<TypingRequest> get typingStream => _typingStreamController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    print('🔌 ===== WebSocket Connect Attempt ===== (print)');
    Logger.debug('🔌 ===== WebSocket Connect Attempt ===== (Logger)');
    print('Current connection state: $_isConnected');
    Logger.debug('Current connection state: $_isConnected');
    
    if (_isConnected) {
      print('⚠️ WebSocket already connected, skipping');
      Logger.debug('⚠️ WebSocket already connected, skipping');
      return;
    }

    try {
      print('📱 Step 1: Getting auth token from SharedPreferences');
      Logger.debug('📱 Step 1: Getting auth token from SharedPreferences');
      
      print('📱 Getting SharedPreferences instance...');
      final prefs = await SharedPreferences.getInstance();
      print('📱 Got SharedPreferences instance');
      
      print('📱 Reading auth_token...');
      _authToken = prefs.getString('auth_token');
      print('📱 Auth token read result: ${_authToken != null ? "Found" : "NULL"}');
      
      if (_authToken == null) {
        print('❌ No auth token found, cannot connect to WebSocket');
        Logger.error('❌ No auth token found, cannot connect to WebSocket');
        return;
      }
      
      print('✅ Auth token found: ${_authToken!.substring(0, 30)}...${_authToken!.substring(_authToken!.length - 10)}');
      Logger.debug('✅ Auth token found: ${_authToken!.substring(0, 30)}...${_authToken!.substring(_authToken!.length - 10)}');

      print('🌐 Step 2: Building WebSocket URL');
      print('Base URL: ${Constants.baseUrl}');
      Logger.debug('🌐 Step 2: Building WebSocket URL');
      Logger.debug('Base URL: ${Constants.baseUrl}');
      
      print('🔄 Converting HTTP to WS protocol...');
      String baseWsUrl = Constants.baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      
      print('After protocol conversion: $baseWsUrl');
      Logger.debug('After protocol conversion: $baseWsUrl');
      
      if (baseWsUrl.endsWith('/api')) {
        print('Removing /api suffix...');
        baseWsUrl = baseWsUrl.substring(0, baseWsUrl.length - 4);
        print('Removed /api suffix: $baseWsUrl');
        Logger.debug('Removed /api suffix: $baseWsUrl');
      }
      
      print('🔗 Building final socket URL...');
      // Remove trailing slash if present to avoid URL issues
      if (baseWsUrl.endsWith('/')) {
        baseWsUrl = baseWsUrl.substring(0, baseWsUrl.length - 1);
      }
      // Use URL without query parameter to avoid # being added by STOMP library
      // The token will be passed in the Sec-WebSocket-Protocol header instead
      final socketUrl = '$baseWsUrl/ws-messaging?token=$_authToken';
      print('✅ Final WebSocket URL: $socketUrl');
      Logger.debug('✅ Final WebSocket URL: $socketUrl');

      print('🔧 Step 3: Creating StompClient configuration');
      Logger.debug('🔧 Step 3: Creating StompClient configuration');
      
      print('🏗️ Instantiating StompClient...');
      _stompClient = StompClient(
        config: StompConfig(
          url: socketUrl,
          onConnect: _onConnect,
          beforeConnect: () async {
            print('⏳ beforeConnect callback - About to connect...');
            Logger.debug('⏳ beforeConnect callback - About to connect...');
          },
          onWebSocketError: (dynamic error) {
            print('❌ WebSocket error: $error');
            print('Error type: ${error.runtimeType}');
            Logger.error('❌ WebSocket error: $error');
            Logger.error('Error type: ${error.runtimeType}');
            _isConnected = false;
            _connectionStateController.add(false);
          },
          onUnhandledFrame: (StompFrame frame) {
            print('🔍 ========== UNHANDLED FRAME ==========');
            print('  Command: ${frame.command}');
            print('  Headers: ${frame.headers}');
            print('  Body: ${frame.body}');
            print('=======================================');
            Logger.debug('🔍 Unhandled frame: command=${frame.command}, body=${frame.body}');
          },
          onUnhandledMessage: (StompFrame frame) {
            print('📨 ========== UNHANDLED MESSAGE ==========');
            print('  Destination: ${frame.headers['destination']}');
            print('  Subscription: ${frame.headers['subscription']}');
            print('  Message-ID: ${frame.headers['message-id']}');
            print('  Body: ${frame.body}');
            print('=========================================');
            Logger.debug('📨 Unhandled MESSAGE: destination=${frame.headers['destination']}');
            
            // Try to handle it anyway
            if (frame.body != null) {
              try {
                final data = jsonDecode(frame.body!);
                print('  📦 Decoded data keys: ${data is Map ? (data as Map).keys.toList() : "not a map"}');
              } catch (e) {
                print('  ❌ Could not decode body: $e');
              }
            }
          },
          onStompError: (StompFrame frame) {
            print('❌ ========== STOMP ERROR ==========');
            print('  Command: ${frame.command}');
            print('  Headers: ${frame.headers}');
            print('  Body: ${frame.body}');
            print('====================================');
            Logger.error('❌ STOMP error frame:');
            Logger.error('  Command: ${frame.command}');
            Logger.error('  Headers: ${frame.headers}');
            Logger.error('  Body: ${frame.body}');
          },
          onUnhandledReceipt: (StompFrame frame) {
            print('📬 ========== RECEIPT ==========');
            print('  Receipt-ID: ${frame.headers['receipt-id']}');
            print('  Headers: ${frame.headers}');
            print('================================');
          },
          onDisconnect: (StompFrame frame) {
            Logger.debug('🔌 WebSocket disconnected');
            Logger.debug('  Frame command: ${frame.command}');
            Logger.debug('  Frame body: ${frame.body}');
            _isConnected = false;
            _connectionStateController.add(false);
          },
          onWebSocketDone: () {
            Logger.debug('✅ WebSocket connection done/closed');
          },
          onDebugMessage: (String message) {
            print('🐛 STOMP Debug: $message');
          },
          stompConnectHeaders: {
            'Authorization': 'Bearer $_authToken',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $_authToken',
            'token': _authToken,
          },
        ),
      );

      print('✅ StompClient created successfully');
      print('🚀 Step 4: Activating StompClient');
      Logger.debug('🚀 Step 4: Activating StompClient');
      
      _stompClient!.activate();
      
      print('✅ StompClient activation initiated');
      Logger.debug('✅ StompClient activation initiated');
      
    } catch (e, stackTrace) {
      print('❌ EXCEPTION in connect(): $e');
      print('Stack trace: $stackTrace');
      Logger.error('❌ Failed to connect to WebSocket: $e');
      Logger.error('Stack trace: $stackTrace');
      _isConnected = false;
      _connectionStateController.add(false);
    }
    
    print('🔌 ===== WebSocket Connect Attempt End =====');
    Logger.debug('🔌 ===== WebSocket Connect Attempt End =====');
  }

  void _onConnect(StompFrame frame) {
    Logger.debug('🎉 ===== WebSocket Connected Successfully =====');
    Logger.debug('Frame command: ${frame.command}');
    Logger.debug('Frame headers: ${frame.headers}');
    Logger.debug('Frame body: ${frame.body}');
    
    _isConnected = true;
    _connectionStateController.add(true);
    
    Logger.debug('✅ Connection state updated to: $_isConnected');
    Logger.debug('📡 Broadcasting connection state to listeners');
    
    // Subscribe to user-specific queues
    Logger.debug('🔔 Subscribing to user-specific queues...');
    _subscribeToUserQueues();
    
    Logger.debug('🎉 ===== WebSocket Setup Complete =====');
  }

  void _subscribeToUserQueues() {
    Logger.debug('📡 _subscribeToUserQueues called');
    Logger.debug('  StompClient null? ${_stompClient == null}');
    Logger.debug('  IsConnected? $_isConnected');
    
    if (_stompClient == null || !_isConnected) {
      Logger.error('❌ Cannot subscribe: client=${_stompClient != null}, connected=$_isConnected');
      return;
    }
    
    Logger.debug('✅ Subscribing to user queues...');
    
    // Subscribe to personal message queue
    Logger.debug('📬 Subscribing to /user/queue/messages');
    print('📬 Subscribing to /user/queue/messages');
    _stompClient!.subscribe(
      destination: '/user/queue/messages',
      callback: (StompFrame frame) {
        print('📥 🎯 RECEIVED on /user/queue/messages');
        print('  Body: ${frame.body}');
        if (frame.body != null) {
          try {
            Logger.debug('📥 Received raw message from /user/queue/messages: ${frame.body}');
            final data = jsonDecode(frame.body!);
            Logger.debug('📥 Decoded JSON: $data');
            final wsMessage = WebSocketMessage.fromJson(data);
            Logger.debug('📥 Parsed WebSocketMessage: type=${wsMessage.type}, conversationId=${wsMessage.conversationId}');
            print('📥 Adding to message stream controller');
            _messageStreamController.add(wsMessage);
          } catch (e, stackTrace) {
            print('❌ Error: $e');
            Logger.error('❌ Error parsing /user/queue/messages: $e');
            Logger.error('Stack trace: $stackTrace');
            Logger.error('Raw body: ${frame.body}');
          }
        }
      },
    );
    
    print('✅ Subscribed to /user/queue/messages');
    Logger.debug('✅ Subscribed to /user/queue/messages');
    
    // Subscribe to reply queue for sent messages
    Logger.debug('📮 Subscribing to /user/queue/reply');
    _stompClient!.subscribe(
      destination: '/user/queue/reply',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            print('📥 Received reply from /user/queue/reply: ${frame.body}');
            Logger.debug('📥 Received reply from /user/queue/reply: ${frame.body}');
            final data = jsonDecode(frame.body!);
            final wsMessage = WebSocketMessage.fromJson(data);
            _messageStreamController.add(wsMessage);
          } catch (e, stackTrace) {
            Logger.error('❌ Error parsing /user/queue/reply: $e');
            Logger.error('Stack trace: $stackTrace');
            Logger.error('Raw body: ${frame.body}');
          }
        }
      },
    );
    
    Logger.debug('✅ Subscribed to /user/queue/reply');
    
    // Subscribe to notification queue
    Logger.debug('🔔 Subscribing to /user/queue/notifications');
    _stompClient!.subscribe(
      destination: '/user/queue/notifications',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            _notificationStreamController.add(data);
            Logger.debug('Received notification: ${data['type']}');
          } catch (e) {
            Logger.error('Error parsing notification: $e');
          }
        }
      },
    );
    
    Logger.debug('✅ Subscribed to /user/queue/notifications');
    
    // Subscribe to error queue
    Logger.debug('❌ Subscribing to /user/queue/errors');
    print('❌ Subscribing to /user/queue/errors');
    _stompClient!.subscribe(
      destination: '/user/queue/errors',
      callback: (StompFrame frame) {
        print('❌ ========== SERVER ERROR RECEIVED ==========');
        print('  Raw body: ${frame.body}');
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            print('❌ Error from server:');
            print('  Type: ${data['type']}');
            print('  Message: ${data['message']}');
            print('  Data: ${data['data']}');
            print('  Timestamp: ${data['timestamp']}');
            print('=============================================');
            Logger.error('⚠️ WebSocket error: ${data['message']}');
            Logger.error('⚠️ Error type: ${data['type']}');
            Logger.error('⚠️ Error data: ${data['data']}');
          } catch (e) {
            print('❌ Could not parse error message: $e');
            Logger.error('⚠️ WebSocket error (raw): ${frame.body}');
          }
        }
      },
    );
    
    print('✅ Subscribed to /user/queue/errors');
    Logger.debug('✅ Subscribed to /user/queue/errors');
    Logger.debug('🎉 All user queues subscribed successfully!');
  }

  void subscribeToConversation(int conversationId) {
    print('💬 ===== Subscribing to Conversation $conversationId =====');
    Logger.debug('💬 ===== Subscribing to Conversation $conversationId =====');
    Logger.debug('  StompClient null? ${_stompClient == null}');
    Logger.debug('  IsConnected? $_isConnected');
    
    if (_stompClient == null || !_isConnected) {
      print('❌ Cannot subscribe: WebSocket not connected');
      Logger.error('❌ Cannot subscribe: WebSocket not connected');
      Logger.error('  Client exists: ${_stompClient != null}');
      Logger.error('  Connected: $_isConnected');
      return;
    }
    
    print('✅ WebSocket is connected, proceeding with subscriptions...');
    
    // Subscribe to conversation messages
    Logger.debug('📨 Subscribing to /topic/conversations/$conversationId');
    print('📨 Subscribing to /topic/conversations/$conversationId');
    _stompClient!.subscribe(
      destination: '/topic/conversations/$conversationId',
      callback: (StompFrame frame) {
        print('📥 🎉 RECEIVED on /topic/conversations/$conversationId');
        print('  Frame body: ${frame.body}');
        if (frame.body != null) {
          try {
            Logger.debug('📥 Received raw message from /topic/conversations/$conversationId: ${frame.body}');
            final data = jsonDecode(frame.body!);
            print('📥 Decoded JSON type: ${data.runtimeType}');
            print('📥 Decoded JSON keys: ${data is Map ? (data as Map).keys.toList() : "not a map"}');
            Logger.debug('📥 Decoded JSON: $data');
            
            // Try to parse as WebSocketMessage first
            try {
              final wsMessage = WebSocketMessage.fromJson(data);
              Logger.debug('📥 Parsed WebSocketMessage: type=${wsMessage.type}, conversationId=${wsMessage.conversationId}');
              print('📥 Successfully parsed as WebSocketMessage: type=${wsMessage.type}');
              print('📥 Adding to message stream controller');
              _messageStreamController.add(wsMessage);
            } catch (wsError) {
              // If not WebSocketMessage format, try direct MessageResponse
              print('⚠️ Not WebSocketMessage format, trying as direct data: $wsError');
              // Create a WebSocketMessage wrapper
              final wsMessage = WebSocketMessage(
                type: 'NEW_MESSAGE',
                data: data,
                conversationId: conversationId,
                senderId: data['senderId'],
                timestamp: DateTime.now(),
              );
              print('📥 Wrapped as WebSocketMessage');
              _messageStreamController.add(wsMessage);
            }
          } catch (e, stackTrace) {
            print('❌ Error parsing message: $e');
            Logger.error('❌ Error parsing /topic/conversations/$conversationId: $e');
            Logger.error('Stack trace: $stackTrace');
            Logger.error('Raw body: ${frame.body}');
          }
        }
      },
    );
    
    print('✅ Subscribed to /topic/conversations/$conversationId');
    Logger.debug('✅ Subscribed to /topic/conversations/$conversationId');
    
    // Subscribe to typing indicators
    Logger.debug('⌨️ Subscribing to /topic/conversations/$conversationId/typing');
    print('⌨️ Subscribing to /topic/conversations/$conversationId/typing');
    _stompClient!.subscribe(
      destination: '/topic/conversations/$conversationId/typing',
      callback: (StompFrame frame) {
        print('⌨️ 🎯 RECEIVED typing indicator on /topic/conversations/$conversationId/typing');
        print('  Body: ${frame.body}');
        if (frame.body != null) {
          try {
            Logger.debug('⌨️ Received typing indicator: ${frame.body}');
            final data = jsonDecode(frame.body!);
            print('  Decoded data: $data');
            
            // Backend sends: {"type":"TYPING","data":{...},"conversationId":3,"senderId":3,"timestamp":"..."}
            // We need to extract the nested 'data' object
            Map<String, dynamic> typingData;
            
            if (data['data'] != null && data['data'] is Map<String, dynamic>) {
              // Has nested data structure
              typingData = data['data'] as Map<String, dynamic>;
              print('  📦 Using nested data structure');
            } else {
              // Flat structure
              typingData = data;
              print('  📦 Using flat structure');
            }
            
            // Handle both 'typing' and 'isTyping' field names
            final isTyping = typingData['isTyping'] ?? typingData['typing'] ?? false;
            
            final typingRequest = TypingRequest(
              conversationId: typingData['conversationId'] as int,
              userId: typingData['userId'] as int,
              username: typingData['username'] as String,
              isTyping: isTyping as bool,
            );
            
            print('  ✅ Parsed typing: user=${typingRequest.userId}, typing=${typingRequest.isTyping}');
            _typingStreamController.add(typingRequest);
            Logger.debug('✅ Typing indicator: user=${typingRequest.userId}, typing=${typingRequest.isTyping}');
          } catch (e, stackTrace) {
            print('  ❌ Error parsing typing: $e');
            Logger.error('❌ Error parsing typing indicator: $e');
            Logger.error('Stack trace: $stackTrace');
            Logger.error('Raw body: ${frame.body}');
          }
        }
      },
    );
    
    Logger.debug('✅ Subscribed to /topic/conversations/$conversationId/typing');
    
    // Subscribe to read receipts
    Logger.debug('👁️ Subscribing to /topic/conversations/$conversationId/read');
    print('👁️ Subscribing to /topic/conversations/$conversationId/read');
    _stompClient!.subscribe(
      destination: '/topic/conversations/$conversationId/read',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            print('👁️ Received read receipt: ${frame.body}');
            Logger.debug('👁️ Received read receipt: ${frame.body}');
            final data = jsonDecode(frame.body!);
            final wsMessage = WebSocketMessage.fromJson(data);
            _messageStreamController.add(wsMessage);
            Logger.debug('✅ Read receipt processed');
          } catch (e, stackTrace) {
            print('❌ Error parsing read receipt: $e');
            Logger.error('❌ Error parsing read receipt: $e');
            Logger.error('Stack trace: $stackTrace');
          }
        }
      },
    );
    
    Logger.debug('✅ Subscribed to /topic/conversations/$conversationId/read');
    Logger.debug('🎉 Conversation $conversationId fully subscribed');
  }

  void unsubscribeFromConversation(int conversationId) {
    if (_stompClient == null || !_isConnected) return;
    
    // Note: stomp_dart_client doesn't provide easy unsubscribe by destination
    // In a production app, you'd want to track subscription IDs
    Logger.debug('Unsubscribed from conversation: $conversationId');
  }

  void subscribeToUserPosts(int userId) {
    print('📝 ===== Subscribing to User Posts $userId =====');
    Logger.debug('📝 ===== Subscribing to User Posts $userId =====');
    
    if (_stompClient == null || !_isConnected) {
      print('❌ Cannot subscribe to posts: WebSocket not connected');
      Logger.error('❌ Cannot subscribe to posts: WebSocket not connected');
      return;
    }
    
    print('✅ WebSocket is connected, subscribing to post updates...');
    
    // Subscribe to post updates for the user
    Logger.debug('📮 Subscribing to /topic/users/$userId/posts');
    print('📮 Subscribing to /topic/users/$userId/posts');
    _stompClient!.subscribe(
      destination: '/topic/users/$userId/posts',
      callback: (StompFrame frame) {
        print('📥 🎉 RECEIVED post update for user $userId');
        print('  Frame body: ${frame.body}');
        if (frame.body != null) {
          try {
            Logger.debug('📥 Received post notification: ${frame.body}');
            final data = jsonDecode(frame.body!);
            print('📥 Post notification type: ${data['type']}');
            Logger.debug('📥 Post notification decoded: $data');
            
            // Send to notification stream
            _notificationStreamController.add(data);
            Logger.debug('✅ Post notification sent to stream: type=${data['type']}');
          } catch (e, stackTrace) {
            print('❌ Error parsing post notification: $e');
            Logger.error('❌ Error parsing post notification: $e');
            Logger.error('Stack trace: $stackTrace');
            Logger.error('Raw body: ${frame.body}');
          }
        }
      },
    );
    
    print('✅ Subscribed to /topic/users/$userId/posts');
    Logger.debug('✅ Subscribed to user posts notifications');
  }

  void sendMessage(int conversationId, SendMessageRequest message) {
    print('🚀 ===== Attempting to send message =====');
    print('ConversationId: $conversationId');
    print('StompClient null? ${_stompClient == null}');
    print('IsConnected? $_isConnected');
    
    if (_stompClient == null || !_isConnected) {
      Logger.error('Cannot send message: WebSocket not connected');
      print('❌ Cannot send: client=${_stompClient != null}, connected=$_isConnected');
      return;
    }
    
    try {
      // Convert MessageType enum to lowercase string matching backend
      String messageTypeStr;
      switch (message.messageType) {
        case MessageType.text:
          messageTypeStr = 'text';
          break;
        case MessageType.image:
          messageTypeStr = 'image';
          break;
        case MessageType.video:
          messageTypeStr = 'video';
          break;
        case MessageType.file:
          messageTypeStr = 'file';
          break;
      }
      
      final payload = {
        'content': message.content,
        'messageType': messageTypeStr,
        if (message.attachmentUrls != null && message.attachmentUrls!.isNotEmpty) 
          'attachmentUrls': message.attachmentUrls
        else
          'attachmentUrls': [],
        if (message.replyToMessageId != null) 
          'replyToMessageId': message.replyToMessageId,
      };
      
      print('📤 Payload: $payload');
      print('📍 Destination: /app/conversations/$conversationId/send');
      final bodyJson = jsonEncode(payload);
      print('📦 Body JSON: $bodyJson');
      print('📦 Body length: ${bodyJson.length} bytes');
      Logger.debug('Sending WebSocket message: $payload');
      
      try {
        final receiptId = 'send-${DateTime.now().millisecondsSinceEpoch}';
        
        print('🔐 Auth token being sent: ${_authToken != null ? "${_authToken!.substring(0, 20)}..." : "NULL"}');
        
        final headers = {
          'content-type': 'application/json',
          'receipt': receiptId,
        };
        
        // Add Authorization header if token exists
        if (_authToken != null) {
          headers['Authorization'] = 'Bearer $_authToken';
          print('✅ Authorization header added to message');
        } else {
          print('⚠️ No auth token available!');
        }
        
        print('📋 Headers: $headers');
        
        _stompClient!.send(
          destination: '/app/conversations/$conversationId/send',
          body: bodyJson,
          headers: headers,
        );
        
        print('✅ STOMP send() method completed without exception');
        print('✅ Message sent to destination: /app/conversations/$conversationId/send');
        print('📬 Waiting for receipt: $receiptId');
        Logger.debug('✅ Sent message to conversation $conversationId via WebSocket');
      } catch (sendError) {
        print('❌ Error in STOMP send(): $sendError');
        throw sendError;
      }
    } catch (e, stackTrace) {
      print('❌ Exception in sendMessage: $e');
      print('Stack trace: $stackTrace');
      Logger.error('❌ Error sending message via WebSocket: $e');
      Logger.error('Stack trace: $stackTrace');
    }
  }

  void sendTypingIndicator(int conversationId, int userId, String username, bool isTyping) {
    print('⌨️ Sending typing indicator: isTyping=$isTyping');
    
    if (_stompClient == null || !_isConnected) {
      print('❌ Cannot send typing: not connected');
      return;
    }
    
    try {
      final payload = {
        'conversationId': conversationId,
        'userId': userId,
        'username': username,
        'isTyping': isTyping,
      };
      
      final bodyJson = jsonEncode(payload);
      print('📤 Typing payload: $payload');
      print('📍 Typing destination: /app/conversations/$conversationId/typing');
      
      final headers = {
        'content-type': 'application/json',
      };
      
      // Add Authorization header if token exists
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      _stompClient!.send(
        destination: '/app/conversations/$conversationId/typing',
        body: bodyJson,
        headers: headers,
      );
      
      print('✅ Typing indicator sent');
      Logger.debug('Sent typing indicator: isTyping=$isTyping');
    } catch (e, stackTrace) {
      print('❌ Error sending typing indicator: $e');
      Logger.error('Error sending typing indicator: $e');
      Logger.error('Stack trace: $stackTrace');
    }
  }

  void markAsRead(int conversationId, int messageId) {
    print('👁️ ===== Marking message as read =====');
    print('ConversationId: $conversationId, MessageId: $messageId');
    
    if (_stompClient == null || !_isConnected) {
      print('❌ Cannot mark as read: not connected');
      return;
    }
    
    try {
      final payload = {
        'conversationId': conversationId,
        'messageId': messageId,
      };
      
      print('📤 Sending read receipt: $payload');
      print('📍 Destination: /app/conversations/$conversationId/read');
      
      final headers = {
        'content-type': 'application/json',
      };
      
      // Add Authorization header if token exists
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      _stompClient!.send(
        destination: '/app/conversations/$conversationId/read',
        body: jsonEncode(payload),
        headers: headers,
      );
      
      print('✅ Read receipt sent successfully');
      Logger.debug('✅ Sent read receipt for message $messageId in conversation $conversationId');
    } catch (e, stackTrace) {
      print('❌ Error marking as read: $e');
      Logger.error('Error marking message as read: $e');
      Logger.error('Stack trace: $stackTrace');
    }
  }

  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
    _connectionStateController.add(false);
    Logger.debug('WebSocket disconnected');
  }

  void dispose() {
    disconnect();
    _messageStreamController.close();
    _typingStreamController.close();
    _notificationStreamController.close();
    _connectionStateController.close();
  }
}
