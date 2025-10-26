import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/logger.dart';

class SearchService {
  Future<Map<String, dynamic>> search(String keyword, {int page = 0, int size = 10, String? token}) async {
    final endpoint = '${Constants.baseUrl}/api/search?keyword=$keyword&page=$page&size=$size';
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
    final endpoint = '${Constants.baseUrl}/api/social/friends/$userId?page=$page&size=$size';
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
    final endpoint = '${Constants.baseUrl}/api/social/friend-requests?page=$page&size=$size';
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
}