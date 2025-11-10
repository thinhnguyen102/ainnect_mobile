import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import '../models/post.dart';
import '../models/comment.dart';
import '../models/page_response.dart';
import '../models/create_post_request.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

Future<PageResponse<UserReaction>> getPostReactions(int postId, {int page = 0, int size = 10}) async {
  final endpoint = '${Constants.baseUrl}/posts/$postId/reactions?page=$page&size=$size';
  Logger.debug('Fetching reactions for post: postId=$postId, page=$page, size=$size');
  try {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(
      Constants.requestTimeout,
      onTimeout: () {
        throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
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
      return PageResponse<UserReaction>.fromJson(
        data,
        (json) => UserReaction.fromJson(json as Map<String, dynamic>),
      );
    } else {
      Logger.error(
        'Failed to fetch reactions',
        error: 'Status code: \${response.statusCode}, Body: \${response.body}',
      );
      return PageResponse<UserReaction>(
        content: [],
        page: PageInfo(number: page, size: size, totalElements: 0, totalPages: 0),
      );
    }
  } catch (e, stackTrace) {
    Logger.error(
      'Error fetching reactions',
      error: e,
      stackTrace: stackTrace,
    );
    return PageResponse<UserReaction>(
      content: [],
      page: PageInfo(number: page, size: size, totalElements: 0, totalPages: 0),
    );
  }
}

class PostService {
  Future<PageResponse<Post>> getPublicFeed({int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/posts/feed?page=$page&size=$size';
    final headers = {
      'Content-Type': 'application/json',
    };
    
    Logger.debug('Fetching public feed: page=$page, size=$size');
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, 
        body: response.body, 
        headers: response.headers
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PageResponse<Post>.fromJson(
          data,
          (json) => Post.fromJson(json as Map<String, dynamic>),
        );
      } else {
        Logger.error(
          'Failed to fetch public feed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return PageResponse<Post>(
          content: [],
          page: PageInfo(
            size: size,
            number: page,
            totalElements: 0,
            totalPages: 0,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.networkError('GET', endpoint, e);
      Logger.error(
        'Error fetching public feed',
        error: e,
        stackTrace: stackTrace,
      );
      return PageResponse<Post>(
        content: [],
        page: PageInfo(
          size: size,
          number: page,
          totalElements: 0,
          totalPages: 0,
        ),
      );
    }
  }

  Future<PageResponse<Post>> getUserFeed(String token, {int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/posts/feed/user?page=$page&size=$size';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    
    Logger.debug('Fetching user feed: page=$page, size=$size');
    Logger.request('GET', endpoint, headers: headers);
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode, 
        body: response.body, 
        headers: response.headers
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PageResponse<Post>.fromJson(
          data,
          (json) => Post.fromJson(json as Map<String, dynamic>),
        );
      } else {
        Logger.error(
          'Failed to fetch user feed',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return PageResponse<Post>(
          content: [],
          page: PageInfo(
            size: size,
            number: page,
            totalElements: 0,
            totalPages: 0,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.networkError('GET', endpoint, e);
      Logger.error(
        'Error fetching user feed',
        error: e,
        stackTrace: stackTrace,
      );
      return PageResponse<Post>(
        content: [],
        page: PageInfo(
          size: size,
          number: page,
          totalElements: 0,
          totalPages: 0,
        ),
      );
    }
  }

  Future<PageResponse<Post>> getPostsByAuthor(int authorId, {int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/posts?authorId=$authorId&page=$page&size=$size';
    Logger.debug('Fetching posts by author: authorId=$authorId, page=$page, size=$size');
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PageResponse<Post>.fromJson(
          data,
          (json) => Post.fromJson(json as Map<String, dynamic>),
        );
      } else {
        Logger.error(
          'Failed to fetch posts by author',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return PageResponse<Post>(
          content: [],
          page: PageInfo(
            size: size,
            number: page,
            totalElements: 0,
            totalPages: 0,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error fetching posts by author',
        error: e,
        stackTrace: stackTrace,
      );
      return PageResponse<Post>(
        content: [],
        page: PageInfo(
          size: size,
          number: page,
          totalElements: 0,
          totalPages: 0,
        ),
      );
    }
  }

  Future<Post?> getPostById(int postId) async {
    final endpoint = '${Constants.baseUrl}/posts/$postId';
    Logger.debug('Fetching post by ID: postId=$postId');
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final post = Post.fromJson(data);
        Logger.debug('Successfully fetched post: ${post.id}');
        return post;
      } else {
        Logger.error(
          'Failed to fetch post by ID',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error fetching post by ID',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> reactToPost(String token, int postId, String reactionType) async {
    final endpoint = '${Constants.baseUrl}/posts/$postId/reactions';
    Logger.debug('Adding reaction to post: postId=$postId, reaction=$reactionType');
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': reactionType.toLowerCase(),
        }),
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      final success = response.statusCode == 200 || response.statusCode == 201;
      if (success) {
        Logger.debug('Successfully added reaction to post $postId');
      } else {
        Logger.error(
          'Failed to add reaction',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Error adding reaction',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> removeReaction(String token, int postId) async {
    final endpoint = '${Constants.baseUrl}/posts/$postId/reactions';
    Logger.debug('Removing reaction from post: postId=$postId');
    
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.api(
        'DELETE',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      final success = response.statusCode == 200 || response.statusCode == 204;
      if (success) {
        Logger.debug('Successfully removed reaction from post $postId');
      } else {
        Logger.error(
          'Failed to remove reaction',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Error removing reaction',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<CommentResponse> getPostComments(String token, int postId, {int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/comments/by-post/$postId?page=$page&size=$size';
    Logger.debug('Fetching comments for post: postId=$postId, page=$page, size=$size');
    
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

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommentResponse.fromJson(data);
      } else {
        Logger.error(
          'Failed to fetch comments',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return CommentResponse(
          comments: [],
          currentPage: page,
          pageSize: size,
          totalElements: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false,
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error fetching comments',
        error: e,
        stackTrace: stackTrace,
      );
      return CommentResponse(
        comments: [],
        currentPage: page,
        pageSize: size,
        totalElements: 0,
        totalPages: 0,
        hasNext: false,
        hasPrevious: false,
      );
    }
  }

  Future<bool> addComment(String token, int postId, String content) async {
    final endpoint = '${Constants.baseUrl}/posts/$postId/comments';
    Logger.debug('Adding comment to post: postId=$postId');
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': content,
        }),
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      final success = response.statusCode == 200 || response.statusCode == 201;
      if (success) {
        Logger.debug('Successfully added comment to post $postId');
      } else {
        Logger.error(
          'Failed to add comment',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Error adding comment',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> sharePost(String token, int postId, {String? comment}) async {
    final endpoint = '${Constants.baseUrl}/posts/$postId/shares';
    Logger.debug('Sharing post: postId=$postId${comment != null ? ', with comment' : ''}');
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (comment != null) 'comment': comment,
        }),
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      final success = response.statusCode == 200 || response.statusCode == 201;
      if (success) {
        Logger.debug('Successfully shared post $postId');
      } else {
        Logger.error(
          'Failed to share post',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Error sharing post',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<Post?> createPost(String token, CreatePostRequest request) async {
    try {
      final endpoint = '${Constants.baseUrl}/posts';
      Logger.api('POST', endpoint);

      // Tạo form data
      final formData = http.MultipartRequest('POST', Uri.parse(endpoint));
      
      // Thêm headers
      formData.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      formData.fields.addAll({
        'content': request.content,
        'visibility': request.visibility,
        if (request.groupId != null) 'groupId': request.groupId.toString(),
      });

      Logger.debug('Uploading ${request.mediaFiles.length} media files');
      for (final filePath in request.mediaFiles) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            String? mimeType;
            final extension = filePath.toLowerCase().split('.').last;
            if (['jpg', 'jpeg'].contains(extension)) {
              mimeType = 'image/jpeg';
            } else if (extension == 'png') {
              mimeType = 'image/png';
            } else if (extension == 'gif') {
              mimeType = 'image/gif';
            } else if (extension == 'webp') {
              mimeType = 'image/webp';
            } else if (extension == 'mp4') {
              mimeType = 'video/mp4';
            } else if (extension == 'mov') {
              mimeType = 'video/quicktime';
            } else if (extension == 'avi') {
              mimeType = 'video/x-msvideo';
            } else if (extension == 'mkv') {
              mimeType = 'video/x-matroska';
            }
            
            final multipartFile = await http.MultipartFile.fromPath(
              'mediaFiles', // Key phải là 'mediaFiles' để backend nhận được
              filePath,
              contentType: mimeType != null ? http_parser.MediaType.parse(mimeType) : null,
            );
            formData.files.add(multipartFile);
            Logger.debug('Added file: $filePath (${mimeType ?? 'auto-detect'})');
          } else {
            Logger.error('File not found: $filePath');
          }
        } catch (e) {
          Logger.error('Error adding file $filePath: $e');
        }
      }

      // Gửi request với timeout dài hơn cho video
      final response = await formData.send().timeout(
        const Duration(seconds: 120), // Tăng timeout cho video
      );
      final responseBody = await response.stream.bytesToString();

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: responseBody,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return Post.fromJson(data);
      } else {
        Logger.error('Create post failed: ${response.statusCode} - $responseBody');
      }

      return null;
    } catch (e, stackTrace) {
      Logger.api(
        'POST',
        '${Constants.baseUrl}/posts',
        error: e,
      );
      Logger.error('Error creating post', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchPostById(int postId, String token) async {
    final endpoint = '${Constants.baseUrl}/posts/$postId';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    Logger.debug('Fetching post by ID: $postId');
    Logger.request('GET', endpoint, headers: headers);

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      Logger.response('GET', endpoint, response.statusCode,
          body: response.body, headers: response.headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Logger.error(
          'Failed to fetch post by ID',
          error: 'Status code: ${response.statusCode}, Body: ${response.body}',
        );
        return {'result': 'FAILURE', 'message': 'Post not found'};
      }
    } catch (e, stackTrace) {
      Logger.networkError('GET', endpoint, e);
      Logger.error(
        'Error fetching post by ID',
        error: e,
        stackTrace: stackTrace,
      );
      return {'result': 'FAILURE', 'message': 'Error: $e'};
    }
  }
}