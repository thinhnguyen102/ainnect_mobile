import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import '../utils/constants.dart';
import '../utils/logger.dart';
import '../models/api_response.dart';
import '../models/group.dart';
import 'media_upload_service.dart';

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
    
    // Upload cover image to Cloudflare first if provided
    String? coverUrl;
    if (coverImage != null) {
      try {
        Logger.debug('Uploading cover image to Cloudflare...');
        final uploadService = MediaUploadService();
        if (!uploadService.isAvailable) {
          throw Exception(uploadService.errorMessage ?? 'Cloudflare R2 chưa được cấu hình');
        }
        
        // Generate unique key for group cover
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = coverImage.path.split('/').last;
        final key = 'groups/covers/${timestamp}_$fileName';
        
        coverUrl = await uploadService.uploadFile(coverImage, key: key);
        Logger.debug('Cover image uploaded successfully: $coverUrl');
      } catch (e) {
        Logger.error('Failed to upload cover image: $e');
        rethrow;
      }
    }

    // Create JSON request body
    final requestBody = {
      'name': name,
      'description': description,
      'visibility': visibility,
      'joinQuestions': joinQuestions,
      if (coverUrl != null) 'coverUrl': coverUrl,
    };

    Logger.debug('Creating group with name: $name');
    Logger.request('POST', endpoint, headers: {'Authorization': 'Bearer $token'}, body: jsonEncode(requestBody));

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

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

    // Upload media files to Cloudflare first if provided
    List<String> mediaUrls = [];
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      try {
        Logger.debug('Uploading ${mediaFiles.length} media files to Cloudflare...');
        final uploadService = MediaUploadService();
        if (!uploadService.isAvailable) {
          throw Exception(uploadService.errorMessage ?? 'Cloudflare R2 chưa được cấu hình');
        }
        
        for (final filePath in mediaFiles) {
          final file = File(filePath);
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = filePath.split('/').last;
          final key = 'posts/groups/$groupId/${timestamp}_$fileName';
          
          final url = await uploadService.uploadFile(file, key: key);
          mediaUrls.add(url);
          Logger.debug('Media uploaded successfully: $url');
        }
      } catch (e) {
        Logger.error('Failed to upload media files: $e');
        rethrow;
        }
      }

    // Create JSON request body
    final requestBody = {
      'content': content,
      'visibility': visibility,
      if (mediaUrls.isNotEmpty) 'mediaUrls': mediaUrls,
    };

    Logger.debug('Creating group post with content: $content');
    Logger.request('POST', endpoint, headers: {'Authorization': 'Bearer $token'}, body: jsonEncode(requestBody));

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

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
    final endpoint = '${Constants.baseUrl}/groups/$groupId';

    try {
      final response = await http.delete(
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