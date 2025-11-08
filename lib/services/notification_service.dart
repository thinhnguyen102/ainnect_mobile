import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/notification_models.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class NotificationService {
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

  // Get user notifications
  Future<List<NotificationResponse>> getUserNotifications({
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final endpoint = '${Constants.baseUrl}/notifications?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir';
    final headers = await _getHeaders();
    
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('GET', endpoint, response.statusCode, body: response.body);
      print('📩 Notifications response: ${response.body}');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(response.body),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        final content = apiResponse.data['content'] as List;
        return content.map((item) => NotificationResponse.fromJson(item)).toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error fetching notifications: $e');
      rethrow;
    }
  }

  // Get notification stats
  Future<NotificationStatsDto> getNotificationStats() async {
    final endpoint = '${Constants.baseUrl}/notifications/stats';
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
        return NotificationStatsDto.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error fetching notification stats: $e');
      rethrow;
    }
  }

  // Mark notification as read
  Future<NotificationResponse> markAsRead(int notificationId) async {
    final endpoint = '${Constants.baseUrl}/notifications/$notificationId/read';
    final headers = await _getHeaders();
    
    Logger.request('PUT', endpoint, headers: headers);
    
    try {
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('PUT', endpoint, response.statusCode, body: response.body);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(response.body),
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
        return NotificationResponse.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      Logger.error('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final endpoint = '${Constants.baseUrl}/notifications/read-all';
    final headers = await _getHeaders();
    
    Logger.request('PUT', endpoint, headers: headers);
    
    try {
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('PUT', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      Logger.error('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    final endpoint = '${Constants.baseUrl}/notifications/$notificationId';
    final headers = await _getHeaders();
    
    Logger.request('DELETE', endpoint, headers: headers);
    
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('DELETE', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      Logger.error('Error deleting notification: $e');
      rethrow;
    }
  }

  // Delete old notifications
  Future<void> deleteOldNotifications() async {
    final endpoint = '${Constants.baseUrl}/notifications/cleanup';
    final headers = await _getHeaders();
    
    Logger.request('DELETE', endpoint, headers: headers);
    
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(Constants.requestTimeout);
      
      Logger.response('DELETE', endpoint, response.statusCode, body: response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete old notifications');
      }
    } catch (e) {
      Logger.error('Error deleting old notifications: $e');
      rethrow;
    }
  }
}
