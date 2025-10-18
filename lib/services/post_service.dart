import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';
import '../models/page_response.dart';
import '../models/create_post_request.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class PostService {
  Future<PageResponse<Post>> getPublicFeed({int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/posts/feed?page=$page&size=$size';
    Logger.debug('Fetching public feed: page=$page, size=$size');
    
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
    Logger.debug('Fetching user feed: page=$page, size=$size');
    
    try {
      final response = await http.get(
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
          'reactionType': reactionType,
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

  Future<CommentResponse> getPostComments(int postId, {int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/posts/$postId/comments?page=$page&size=$size';
    Logger.debug('Fetching comments for post: postId=$postId, page=$page, size=$size');
    
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

      // Thêm các trường dữ liệu
      formData.fields.addAll({
        'content': request.content,
        'visibility': request.visibility,
        if (request.groupId != null) 'groupId': request.groupId.toString(),
      });

      // Thêm files
      for (final filePath in request.mediaFiles) {
        final file = await http.MultipartFile.fromPath('mediaFiles', filePath);
        formData.files.add(file);
      }

      // Gửi request
      final response = await formData.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      Logger.api(
        'POST',
        endpoint,
        statusCode: response.statusCode,
        response: responseBody,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return Post.fromJson(data);
      }

      return null;
    } catch (e) {
      Logger.api(
        'POST',
        '${Constants.baseUrl}/posts',
        error: e,
      );
      return null;
    }
  }
}