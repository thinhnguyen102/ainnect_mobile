import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import '../utils/constants.dart';
import '../utils/logger.dart';
import '../models/api_response.dart';
import '../models/group.dart';

class GroupService {
  Future<Group?> createGroup({
    required String name,
    required String description,
    required String visibility,
    File? coverImage,
    required List<Map<String, dynamic>> joinQuestions,
    required String token,
  }) async {
    final endpoint = '${Constants.baseUrl}/groups'; 
    final request = http.MultipartRequest('POST', Uri.parse(endpoint));

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['visibility'] = visibility;
    request.fields['joinQuestions'] = jsonEncode(joinQuestions);

    if (coverImage != null) {
      request.files.add(await http.MultipartFile.fromPath('coverImage', coverImage.path));
    }

    request.headers['Authorization'] = 'Bearer $token'; 

    Logger.debug('Creating group with name: $name');

    try {
      final streamedResponse = await request.send().timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      Logger.response('POST', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse<Group>.fromJson(
          data,
          (json) => Group.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.result == 'SUCCESS') {
          Logger.debug('Successfully created group: ${apiResponse.data.id}');
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 'Failed to create group';
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      Logger.error('Error creating group', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchGroups({
    int page = 0,
    int size = 10,
    required String token, 
  }) async {
    final endpoint = '${Constants.baseUrl}/groups?page=$page&size=$size';

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch groups: ${response.body}');
      }
    } catch (e, stackTrace) {
      Logger.error('Error fetching groups', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchGroupDetail(int groupId, {required String token}) async {
    final endpoint = '${Constants.baseUrl}/groups/$groupId';

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch group details: ${response.body}');
      }
    } catch (e, stackTrace) {
      Logger.error('Error fetching group details', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchGroupPosts({
    required int groupId,
    int page = 0,
    int size = 10,
    required String token,
  }) async {
    final endpoint = '${Constants.baseUrl}/posts/groups/$groupId?page=$page&size=$size';

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch group posts: ${response.body}');
      }
    } catch (e, stackTrace) {
      Logger.error('Error fetching group posts', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUserGroups({
    required int userId,
    int page = 0,
    int size = 10,
    required String token,
  }) async {
    final endpoint = '${Constants.baseUrl}/groups/member/$userId?page=$page&size=$size';

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch user groups: ${response.body}');
      }
    } catch (e, stackTrace) {
      Logger.error('Error fetching user groups', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGroupPost({
    required int groupId,
    required String content,
    required String visibility, 
    List<String>? mediaFiles,
    required String token,
  }) async {
    final endpoint = '${Constants.baseUrl}/posts/groups/$groupId';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['content'] = content;
      request.fields['visibility'] = visibility; // Added visibility field

      if (mediaFiles != null) {
        for (final filePath in mediaFiles) {
          request.files.add(await http.MultipartFile.fromPath('mediaFiles', filePath));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Logger.response('POST', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create group post: ${response.body}');
      }
    } catch (e, stackTrace) {
      Logger.error('Error creating group post', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> joinGroup({
    required int groupId,
    required String token,
  }) async {
    final endpoint = '${Constants.baseUrl}/groups/$groupId/join';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('POST', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to join group: ${response.body}');
      }
    } catch (e, stackTrace) {
      Logger.error('Error joining group', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> leaveGroup({
    required int groupId,
    required String token,
  }) async {
    final endpoint = '${Constants.baseUrl}/groups/$groupId/leave';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('POST', endpoint, response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to leave group: ${response.body}');
      }
    } catch (e, stackTrace) {
      Logger.error('Error leaving group', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}