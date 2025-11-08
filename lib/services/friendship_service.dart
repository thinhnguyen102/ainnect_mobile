import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/friendship_models.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class FriendshipService {
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

  // Send friend request
  Future<FriendshipResponse> sendFriendRequest(int otherUserId) async {
    final endpoint = '${Constants.baseUrl}/social/friend-request';
    final headers = await _getHeaders();
    final body = jsonEncode({'friendId': otherUserId});
    
    Logger.request('POST', endpoint, headers: headers, body: body);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('POST', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        // The response has nested data structure
        final friendshipData = apiResponse.data['data'] as Map<String, dynamic>;
        return FriendshipResponse.fromJson(friendshipData);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error sending friend request: $e');
      rethrow;
    }
  }

  // Accept friend request
  Future<FriendshipResponse> acceptFriendRequest(int otherUserId) async {
    final endpoint = '${Constants.baseUrl}/social/friend-request/accept';
    final headers = await _getHeaders();
    final body = jsonEncode({'friendId': otherUserId});
    
    Logger.request('POST', endpoint, headers: headers, body: body);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('POST', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        return FriendshipResponse.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error accepting friend request: $e');
      rethrow;
    }
  }

  // Reject friend request
  Future<void> rejectFriendRequest(int otherUserId) async {
    final endpoint = '${Constants.baseUrl}/social/friend-request/reject';
    final headers = await _getHeaders();
    final body = jsonEncode({'friendId': otherUserId});
    
    Logger.request('POST', endpoint, headers: headers, body: body);
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('POST', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to reject friend request');
      }
    } catch (e) {
      Logger.error('Error rejecting friend request: $e');
      rethrow;
    }
  }

  // Get friend requests list
  Future<FriendRequestListResponse> getFriendRequests({
    int page = 0,
    int size = 10,
  }) async {
    final endpoint = '${Constants.baseUrl}/social/friend-requests?page=$page&size=$size';
    final headers = await _getHeaders();
    
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('GET', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        return FriendRequestListResponse.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error fetching friend requests: $e');
      rethrow;
    }
  }

  // Get social stats (includes friendship status, followers, following, etc.)
  Future<SocialStats?> getSocialStats(int userId) async {
    final endpoint = '${Constants.baseUrl}/social/stats/$userId';
    final headers = await _getHeaders();
    
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('GET', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
          (json) => json as Map<String, dynamic>,
        );
        
        if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
          return SocialStats.fromJson(apiResponse.data);
        }
      }
      
      return null;
    } catch (e) {
      Logger.error('Error fetching social stats: $e');
      return null;
    }
  }

  // Check if users are friends (legacy method, use getSocialStats instead)
  Future<bool> isFriend(int otherUserId) async {
    final stats = await getSocialStats(otherUserId);
    return stats?.friend ?? false;
  }

  // Unfriend/Remove friend
  Future<void> unfriend(int otherUserId) async {
    final endpoint = '${Constants.baseUrl}/social/friend/$otherUserId';
    final headers = await _getHeaders();
    
    Logger.request('DELETE', endpoint, headers: headers);
    
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('DELETE', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to unfriend');
      }
    } catch (e) {
      Logger.error('Error unfriending: $e');
      rethrow;
    }
  }

  // Get common friends
  Future<List<Map<String, dynamic>>> getCommonFriends({
    required int otherUserId,
    int page = 0,
    int size = 10,
  }) async {
    final endpoint = '${Constants.baseUrl}/social/common-friends/$otherUserId?page=$page&size=$size';
    final headers = await _getHeaders();
    
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('GET', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        final commonFriends = apiResponse.data['commonFriends'] as List;
        return commonFriends.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      Logger.error('Error fetching common friends: $e');
      return [];
    }
  }

  // Get common friends count (deprecated - use SocialStats.friendsCount instead)
  @Deprecated('Use getSocialStats(userId).friendsCount instead')
  Future<int> getCommonFriendsCount(int otherUserId) async {
    // Use the new social stats API instead
    final stats = await getSocialStats(otherUserId);
    return stats?.friendsCount ?? 0;
  }
}
