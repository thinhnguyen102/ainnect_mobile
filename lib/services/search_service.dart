import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/logger.dart';

class SearchService {
  Future<Map<String, dynamic>> search(String keyword, {int page = 0, int size = 10, String? token}) async {
    final endpoint = '${Constants.baseUrl}/search?keyword=$keyword&page=$page&size=$size';
    Logger.debug('Searching with keyword: $keyword, page: $page, size: $size');

    try {
      Logger.debug('Preparing to send search request with keyword: $keyword');
      Logger.debug('Sending GET request to: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Search failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return {};
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during search',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchFriends(String userId, {int page = 0, int size = 10, String? token}) async {
    final endpoint = '${Constants.baseUrl}/social/friends/$userId?page=$page&size=$size';
    Logger.debug('Fetching friends for userId: $userId, page: $page, size: $size');

    try {
      Logger.debug('Sending GET request to: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Fetch friends failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return {};
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during fetch friends',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchFriendRequests({int page = 0, int size = 10, String? token}) async {
    final endpoint = '${Constants.baseUrl}/social/friend-requests?page=$page&size=$size';
    Logger.debug('Fetching friend requests, page: $page, size: $size');

    try {
      Logger.debug('Sending GET request to: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Fetch friend requests failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return {};
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during fetch friend requests',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchSentFriendRequests({int page = 0, int size = 10, String? token}) async {
    final endpoint = '${Constants.baseUrl}/social/sent-friend-requests?page=$page&size=$size';
    Logger.debug('Fetching sent friend requests, page: $page, size: $size');

    try {
      Logger.debug('Sending GET request to: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Fetch sent friend requests failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return {};
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during fetch sent friend requests',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  // Send friend request
  Future<Map<String, dynamic>> sendFriendRequest(int friendId, String token) async {
    final endpoint = '${Constants.baseUrl}/social/friend-request';
    Logger.debug('Sending friend request to userId: $friendId');

    try {
      Logger.debug('Sending POST request to: $endpoint');
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'friendId': friendId,
        }),
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Send friend request failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to send friend request');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during send friend request',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Accept friend request
  Future<Map<String, dynamic>> acceptFriendRequest(int otherUserId, String token) async {
    final endpoint = '${Constants.baseUrl}/social/friend-request/accept';
    Logger.debug('Accepting friend request from userId: $otherUserId');

    try {
      Logger.debug('Sending POST request to: $endpoint');
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otherUserId': otherUserId,
        }),
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Accept friend request failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to accept friend request');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during accept friend request',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Reject friend request
  Future<Map<String, dynamic>> rejectFriendRequest(int otherUserId, String token) async {
    final endpoint = '${Constants.baseUrl}/social/friend-request/reject';
    Logger.debug('Rejecting friend request from userId: $otherUserId');

    try {
      Logger.debug('Sending POST request to: $endpoint');
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otherUserId': otherUserId,
        }),
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Reject friend request failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to reject friend request');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during reject friend request',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Cancel sent friend request
  Future<Map<String, dynamic>> cancelFriendRequest(int otherUserId, String token) async {
    final endpoint = '${Constants.baseUrl}/social/friend-request/cancel';
    Logger.debug('Canceling friend request to userId: $otherUserId');

    try {
      Logger.debug('Sending POST request to: $endpoint');
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otherUserId': otherUserId,
        }),
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Cancel friend request failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to cancel friend request');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during cancel friend request',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Unfriend (remove friend)
  Future<Map<String, dynamic>> unfriend(int friendId, String token) async {
    final endpoint = '${Constants.baseUrl}/social/friend/$friendId';
    Logger.debug('Unfriending userId: $friendId');

    try {
      Logger.debug('Sending DELETE request to: $endpoint');
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.api(
        'DELETE',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        Logger.error(
          'Unfriend failed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to unfriend');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during unfriend',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}