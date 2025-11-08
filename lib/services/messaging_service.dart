import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/messaging_models.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class MessagingService {
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create a new conversation
  Future<ConversationResponse> createConversation(CreateConversationRequest request) async {
    final endpoint = '${Constants.baseUrl}/messaging/conversations';
    final headers = await _getHeaders();
    final body = jsonEncode(request.toJson());
    
    Logger.request('POST', endpoint, headers: headers, body: body);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('POST', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(response.body),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        return ConversationResponse.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error creating conversation: $e');
      rethrow;
    }
  }

  // Get user's conversations
  Future<ConversationListResponse> getUserConversations({
    int page = 0,
    int size = 10,
  }) async {
    final endpoint = '${Constants.baseUrl}/messaging/conversations?page=$page&size=$size';
    final headers = await _getHeaders();
    
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('GET', endpoint, response.statusCode, body: response.body);
      
      final jsonData = jsonDecode(response.body);
      Logger.debug('Decoded JSON: $jsonData');
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonData,
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS') {
        if (apiResponse.data != null) {
          Logger.debug('Parsing ConversationListResponse from: ${apiResponse.data}');
          
          // Log detailed structure
          Logger.debug('Data keys: ${apiResponse.data!.keys.toList()}');
          Logger.debug('hasNext value: ${apiResponse.data!['hasNext']} (type: ${apiResponse.data!['hasNext'].runtimeType})');
          Logger.debug('hasPrevious value: ${apiResponse.data!['hasPrevious']} (type: ${apiResponse.data!['hasPrevious'].runtimeType})');
          
          // Log conversations array
          if (apiResponse.data!['conversations'] != null) {
            final conversations = apiResponse.data!['conversations'] as List;
            Logger.debug('Conversations count: ${conversations.length}');
            if (conversations.isNotEmpty) {
              final firstConv = conversations[0] as Map<String, dynamic>;
              Logger.debug('First conversation keys: ${firstConv.keys.toList()}');
              Logger.debug('member value: ${firstConv['member']} (type: ${firstConv['member'].runtimeType})');
              
              // Check lastMessage
              if (firstConv['lastMessage'] != null) {
                final lastMsg = firstConv['lastMessage'] as Map<String, dynamic>;
                Logger.debug('Last message keys: ${lastMsg.keys.toList()}');
                Logger.debug('isRead value: ${lastMsg['isRead']} (type: ${lastMsg['isRead']?.runtimeType})');
                Logger.debug('isEdited value: ${lastMsg['isEdited']} (type: ${lastMsg['isEdited']?.runtimeType})');
              }
            }
          }
          
          return ConversationListResponse.fromJson(apiResponse.data);
        } else {
          // Return empty list if no data
          return ConversationListResponse(
            conversations: [],
            currentPage: 0,
            pageSize: 10,
            totalElements: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
          );
        }
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e, stackTrace) {
      Logger.error('Error fetching conversations: $e');
      Logger.error('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get a specific conversation
  Future<ConversationResponse> getConversation(int conversationId) async {
    final endpoint = '${Constants.baseUrl}/messaging/conversations/$conversationId';
    final headers = await _getHeaders();
    
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('GET', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(response.body),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        return ConversationResponse.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error fetching conversation: $e');
      rethrow;
    }
  }

  // Get messages in a conversation
  Future<MessageListResponse> getConversationMessages(
    int conversationId, {
    int page = 0,
    int size = 20,
  }) async {
    final endpoint = '${Constants.baseUrl}/messaging/conversations/$conversationId/messages?page=$page&size=$size';
    final headers = await _getHeaders();
    
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('GET', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(response.body),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        return MessageListResponse.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error fetching messages: $e');
      rethrow;
    }
  }

  // Mark conversation as read
  Future<void> markAsRead(int conversationId, int messageId) async {
    final endpoint = '${Constants.baseUrl}/messaging/conversations/$conversationId/read';
    final headers = await _getHeaders();
    final body = jsonEncode({
      'conversationId': conversationId,
      'messageId': messageId,
    });
    
    Logger.request('POST', endpoint, headers: headers, body: body);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('POST', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read');
      }
    } catch (e) {
      Logger.error('Error marking as read: $e');
      rethrow;
    }
  }

  // React to a message
  Future<void> reactToMessage(int messageId, String reactionType) async {
    final endpoint = '${Constants.baseUrl}/messaging/messages/$messageId/reactions?type=$reactionType';
    final headers = await _getHeaders();
    
    Logger.request('POST', endpoint, headers: headers);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('POST', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to add reaction');
      }
    } catch (e) {
      Logger.error('Error adding reaction: $e');
      rethrow;
    }
  }

  // Remove reaction from message
  Future<void> removeReaction(int messageId) async {
    final endpoint = '${Constants.baseUrl}/messaging/messages/$messageId/reactions';
    final headers = await _getHeaders();
    
    Logger.request('DELETE', endpoint, headers: headers);
    
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('DELETE', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to remove reaction');
      }
    } catch (e) {
      Logger.error('Error removing reaction: $e');
      rethrow;
    }
  }

  // Upload file and send message
  Future<MessageResponse> uploadAndSendMessage(
    int conversationId,
    String filePath,
  ) async {
    final endpoint = '${Constants.baseUrl}/messaging/conversations/$conversationId/messages/upload';
    final token = await _getAuthToken();
    
    Logger.request('POST', endpoint, headers: {'Authorization': 'Bearer $token'});
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse(endpoint));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send().timeout(Constants.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      Logger.response('POST', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(response.body),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        return MessageResponse.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error uploading file: $e');
      rethrow;
    }
  }
}
