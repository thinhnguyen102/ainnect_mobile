import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/comment.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class CommentService {
  // Get replies for a comment
  Future<CommentResponse?> getCommentReplies(
    String token,
    int commentId, {
    int page = 0,
    int size = 5,
  }) async {
    final endpoint = '${Constants.baseUrl}/comments/$commentId/replies?page=$page&size=$size';
    debugPrint('🔍 Fetching replies for comment $commentId, page: $page');
    debugPrint('📡 API endpoint: $endpoint');

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

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final commentResponse = CommentResponse.fromJson(data);
        debugPrint('✅ Got ${commentResponse.comments.length} replies');
        return commentResponse;
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching replies: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error fetching comment replies', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Create a reply to a comment
  Future<Map<String, dynamic>> createReply(
    String token,
    int commentId,
    String content,
  ) async {
    final endpoint = '${Constants.baseUrl}/comments/$commentId/replies';
    debugPrint('💬 Creating reply for comment $commentId');
    debugPrint('📡 API endpoint: $endpoint');

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseBody = utf8.decode(response.bodyBytes);
          debugPrint('📄 Decoded response body: $responseBody');
          
          // Try to parse as JSON
          final data = jsonDecode(responseBody);
          debugPrint('📦 Parsed data type: ${data.runtimeType}');
          
          // If response is just an ID (int), it means success but no full object returned
          if (data is int) {
            debugPrint('✅ Reply created with ID: $data');
            return {
              'success': true,
              'message': 'Trả lời thành công',
              'commentId': data,
            };
          }
          
          // If response is a Map, parse as ApiResponse
          if (data is Map<String, dynamic>) {
            final apiResponse = ApiResponse<Comment>.fromJson(
              data,
              (json) => Comment.fromJson(json as Map<String, dynamic>),
            );

            if (apiResponse.result == 'SUCCESS') {
              return {
                'success': true,
                'message': apiResponse.message ?? 'Trả lời thành công',
                'comment': apiResponse.data,
              };
            } else {
              return {
                'success': false,
                'message': apiResponse.message ?? 'Trả lời thất bại',
              };
            }
          }
          
          // Unknown response format
          return {
            'success': false,
            'message': 'Định dạng response không hợp lệ',
          };
        } catch (e, stackTrace) {
          debugPrint('❌ Error parsing response: $e');
          debugPrint('📚 Stack trace: $stackTrace');
          return {
            'success': false,
            'message': 'Lỗi parse response: $e',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          'tokenExpired': true,
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': false,
          'message': data['message'] ?? 'Nội dung không hợp lệ',
        };
      } else {
        return {
          'success': false,
          'message': 'Trả lời thất bại. Vui lòng thử lại.',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating reply: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error creating reply', error: e, stackTrace: stackTrace);

      if (e is TimeoutException) {
        return {
          'success': false,
          'message': 'Không thể kết nối đến server. Vui lòng thử lại sau.',
        };
      }

      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.',
      };
    }
  }

  // React to a comment
  Future<Map<String, dynamic>> reactToComment(
    String token,
    int commentId,
    String reactionType,
  ) async {
    final endpoint = '${Constants.baseUrl}/comments/$commentId/reactions';
    debugPrint('❤️ Reacting to comment $commentId with $reactionType');
    debugPrint('📡 API endpoint: $endpoint');

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(data, (json) => json);

        if (apiResponse.result == 'SUCCESS') {
          return {
            'success': true,
            'message': apiResponse.message ?? 'Phản ứng thành công',
          };
        } else {
          return {
            'success': false,
            'message': apiResponse.message ?? 'Phản ứng thất bại',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          'tokenExpired': true,
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': false,
          'message': data['message'] ?? 'Phản ứng không hợp lệ',
        };
      } else {
        return {
          'success': false,
          'message': 'Phản ứng thất bại. Vui lòng thử lại.',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error reacting to comment: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error reacting to comment', error: e, stackTrace: stackTrace);

      if (e is TimeoutException) {
        return {
          'success': false,
          'message': 'Không thể kết nối đến server. Vui lòng thử lại sau.',
        };
      }

      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.',
      };
    }
  }

  // Delete a comment
  Future<Map<String, dynamic>> deleteComment(String token, int commentId) async {
    final endpoint = '${Constants.baseUrl}/comments/$commentId';
    debugPrint('🗑️ Deleting comment $commentId');
    debugPrint('📡 API endpoint: $endpoint');

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

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final apiResponse = ApiResponse.fromJson(data, (json) => json);

          if (apiResponse.result == 'SUCCESS') {
            return {
              'success': true,
              'message': apiResponse.message ?? 'Xóa bình luận thành công',
            };
          }
        }

        return {
          'success': true,
          'message': 'Xóa bình luận thành công',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          'tokenExpired': true,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Bạn không có quyền xóa bình luận này',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Bình luận không tồn tại',
        };
      } else {
        return {
          'success': false,
          'message': 'Xóa bình luận thất bại. Vui lòng thử lại.',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting comment: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error deleting comment', error: e, stackTrace: stackTrace);

      if (e is TimeoutException) {
        return {
          'success': false,
          'message': 'Không thể kết nối đến server. Vui lòng thử lại sau.',
        };
      }

      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.',
      };
    }
  }
}
