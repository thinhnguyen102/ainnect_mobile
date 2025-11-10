import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../models/api_response.dart';
import '../models/update_profile_request.dart';
import '../models/education_request.dart';
import '../models/work_experience_request.dart';
import '../models/interest_request.dart';
import '../models/location_request.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class ProfileService {
  Future<Profile?> getProfile(String token, int userId, {int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/profiles/$userId?page=$page&size=$size';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    Logger.debug('Fetching profile for userId: $userId, page: $page, size: $size');
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
        debugPrint('✅ API request successful');
        final data = jsonDecode(response.body);
        debugPrint('🔄 Parsing response data: $data');
        
        try {
          final apiResponse = ApiResponse<Profile>.fromJson(
            data,
            (json) => Profile.fromJson(json as Map<String, dynamic>),
          );
          debugPrint('✨ API response result: ${apiResponse.result}');
          debugPrint('📝 API response message: ${apiResponse.message}');
          
          if (apiResponse.result == 'SUCCESS') {
            debugPrint('🎉 Successfully parsed profile data');
            debugPrint('👤 Profile data: ${apiResponse.data}');
            return apiResponse.data;
          } else {
            debugPrint('❌ API returned non-success result');
            return null;
          }
        } catch (parseError, parseStack) {
          debugPrint('❌ Error parsing response: $parseError');
          debugPrint('📚 Parse error stack trace: $parseStack');
          return null;
        }
      }
      
      debugPrint('❌ API request failed with status: ${response.statusCode}');
      Logger.error(
        'Failed to fetch profile',
        error: 'Status code: ${response.statusCode}, Body: ${response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      Logger.networkError('GET', endpoint, e);
      Logger.error(
        'Error fetching profile',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<PostsResponse?> getUserPosts(String token, int userId, {int page = 0, int size = 20}) async {
    final endpoint = '${Constants.baseUrl}/profiles/$userId/posts?page=$page&size=$size';
    debugPrint('🔍 Fetching user posts for userId: $userId, page: $page, size: $size');
    debugPrint('📡 API endpoint: $endpoint');
    
    try {
      debugPrint('⏳ Making API request...');
      debugPrint('🔑 Using token: $token');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          debugPrint('⚠️ API timeout after ${Constants.requestTimeout.inSeconds} seconds');
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      debugPrint('📥 API response status: ${response.statusCode}');
      debugPrint('📄 API response body: ${response.body}');

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ API request successful');
        final data = jsonDecode(response.body);
        debugPrint('🔄 Parsing response data: $data');
        
        try {
          final apiResponse = ApiResponse<PostsResponse>.fromJson(
            data,
            (json) => PostsResponse.fromJson(json as Map<String, dynamic>),
          );
          debugPrint('✨ API response result: ${apiResponse.result}');
          debugPrint('📝 API response message: ${apiResponse.message}');
          
          if (apiResponse.result == 'SUCCESS') {
            debugPrint('🎉 Successfully parsed posts data');
            debugPrint('📱 Posts data: ${apiResponse.data}');
            return apiResponse.data;
          } else {
            debugPrint('❌ API returned non-success result');
            return null;
          }
        } catch (parseError, parseStack) {
          debugPrint('❌ Error parsing response: $parseError');
          debugPrint('📚 Parse error stack trace: $parseStack');
          return null;
        }
      }
      
      debugPrint('❌ API request failed with status: ${response.statusCode}');
      Logger.error(
        'Failed to fetch user posts',
        error: 'Status code: ${response.statusCode}, Body: ${response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching user posts: $e');
      debugPrint('📚 Error stack trace: $stackTrace');
      Logger.error(
        'Error fetching user posts',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<List<Education>> getEducations(String token) async {
    final endpoint = '${Constants.baseUrl}/profiles/education';
    debugPrint('🔍 Fetching educations');
    debugPrint('📡 API endpoint: $endpoint');
    
    try {
      debugPrint('⏳ Making API request...');
      debugPrint('🔑 Using token: $token');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          debugPrint('⚠️ API timeout after ${Constants.requestTimeout.inSeconds} seconds');
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      debugPrint('📥 API response status: ${response.statusCode}');
      debugPrint('📄 API response body: ${response.body}');

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ API request successful');
        final data = jsonDecode(response.body);
        debugPrint('🔄 Parsing response data: $data');
        
        try {
          final apiResponse = ApiResponse<List<dynamic>>.fromJson(
            data,
            (json) => json as List<dynamic>,
          );
          final educations = (apiResponse.data as List)
              .map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('✨ API response result: ${apiResponse.result}');
          debugPrint('📝 API response message: ${apiResponse.message}');
          
          if (apiResponse.result == 'SUCCESS') {
            debugPrint('🎉 Successfully parsed educations data');
            debugPrint('🎓 Educations data: $educations');
            return educations;
          } else {
            debugPrint('❌ API returned non-success result');
            return [];
          }
        } catch (parseError, parseStack) {
          debugPrint('❌ Error parsing response: $parseError');
          debugPrint('📚 Parse error stack trace: $parseStack');
          return [];
        }
      }
      
      debugPrint('❌ API request failed with status: ${response.statusCode}');
      Logger.error(
        'Failed to fetch educations',
        error: 'Status code: ${response.statusCode}, Body: ${response.body}',
      );
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching educations: $e');
      debugPrint('📚 Error stack trace: $stackTrace');
      Logger.error(
        'Error fetching educations',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<WorkExperience>> getWorkExperiences(String token) async {
    final endpoint = '${Constants.baseUrl}/profiles/work-experience';
    debugPrint('🔍 Fetching work experiences');
    debugPrint('📡 API endpoint: $endpoint');
    
    try {
      debugPrint('⏳ Making API request...');
      debugPrint('🔑 Using token: $token');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          debugPrint('⚠️ API timeout after ${Constants.requestTimeout.inSeconds} seconds');
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      debugPrint('📥 API response status: ${response.statusCode}');
      debugPrint('📄 API response body: ${response.body}');

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ API request successful');
        final data = jsonDecode(response.body);
        debugPrint('🔄 Parsing response data: $data');
        
        try {
          final apiResponse = ApiResponse<List<dynamic>>.fromJson(
            data,
            (json) => json as List<dynamic>,
          );
          final experiences = (apiResponse.data as List)
              .map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('✨ API response result: ${apiResponse.result}');
          debugPrint('📝 API response message: ${apiResponse.message}');
          
          if (apiResponse.result == 'SUCCESS') {
            debugPrint('🎉 Successfully parsed work experiences data');
            debugPrint('💼 Work experiences data: $experiences');
            return experiences;
          } else {
            debugPrint('❌ API returned non-success result');
            return [];
          }
        } catch (parseError, parseStack) {
          debugPrint('❌ Error parsing response: $parseError');
          debugPrint('📚 Parse error stack trace: $parseStack');
          return [];
        }
      }
      
      debugPrint('❌ API request failed with status: ${response.statusCode}');
      Logger.error(
        'Failed to fetch work experiences',
        error: 'Status code: ${response.statusCode}, Body: ${response.body}',
      );
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching work experiences: $e');
      debugPrint('📚 Error stack trace: $stackTrace');
      Logger.error(
        'Error fetching work experiences',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<Interest>> getInterests(String token) async {
    final endpoint = '${Constants.baseUrl}/profiles/interest';
    debugPrint('🔍 Fetching interests');
    debugPrint('📡 API endpoint: $endpoint');
    
    try {
      debugPrint('⏳ Making API request...');
      debugPrint('🔑 Using token: $token');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          debugPrint('⚠️ API timeout after ${Constants.requestTimeout.inSeconds} seconds');
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      debugPrint('📥 API response status: ${response.statusCode}');
      debugPrint('📄 API response body: ${response.body}');

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ API request successful');
        final data = jsonDecode(response.body);
        debugPrint('🔄 Parsing response data: $data');
        
        try {
          final apiResponse = ApiResponse<List<dynamic>>.fromJson(
            data,
            (json) => json as List<dynamic>,
          );
          final interests = (apiResponse.data as List)
              .map((e) => Interest.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('✨ API response result: ${apiResponse.result}');
          debugPrint('📝 API response message: ${apiResponse.message}');
          
          if (apiResponse.result == 'SUCCESS') {
            debugPrint('🎉 Successfully parsed interests data');
            debugPrint('🎯 Interests data: $interests');
            return interests;
          } else {
            debugPrint('❌ API returned non-success result');
            return [];
          }
        } catch (parseError, parseStack) {
          debugPrint('❌ Error parsing response: $parseError');
          debugPrint('📚 Parse error stack trace: $parseStack');
          return [];
        }
      }
      
      debugPrint('❌ API request failed with status: ${response.statusCode}');
      Logger.error(
        'Failed to fetch interests',
        error: 'Status code: ${response.statusCode}, Body: ${response.body}',
      );
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching interests: $e');
      debugPrint('📚 Error stack trace: $stackTrace');
      Logger.error(
        'Error fetching interests',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<UserLocation>> getLocations(String token) async {
    final endpoint = '${Constants.baseUrl}/profiles/location';
    debugPrint('🔍 Fetching locations');
    debugPrint('📡 API endpoint: $endpoint');
    
    try {
      debugPrint('⏳ Making API request...');
      debugPrint('🔑 Using token: $token');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Constants.requestTimeout,
        onTimeout: () {
          debugPrint('⚠️ API timeout after ${Constants.requestTimeout.inSeconds} seconds');
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );

      debugPrint('📥 API response status: ${response.statusCode}');
      debugPrint('📄 API response body: ${response.body}');

      Logger.api(
        'GET',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ API request successful');
        final data = jsonDecode(response.body);
        debugPrint('🔄 Parsing response data: $data');
        
        try {
          final apiResponse = ApiResponse<List<dynamic>>.fromJson(
            data,
            (json) => json as List<dynamic>,
          );
          final locations = (apiResponse.data as List)
              .map((e) => UserLocation.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('✨ API response result: ${apiResponse.result}');
          debugPrint('📝 API response message: ${apiResponse.message}');
          
          if (apiResponse.result == 'SUCCESS') {
            debugPrint('🎉 Successfully parsed locations data');
            debugPrint('📍 Locations data: $locations');
            return locations;
          } else {
            debugPrint('❌ API returned non-success result');
            return [];
          }
        } catch (parseError, parseStack) {
          debugPrint('❌ Error parsing response: $parseError');
          debugPrint('📚 Parse error stack trace: $parseStack');
          return [];
        }
      }
      
      debugPrint('❌ API request failed with status: ${response.statusCode}');
      Logger.error(
        'Failed to fetch locations',
        error: 'Status code: ${response.statusCode}, Body: ${response.body}',
      );
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching locations: $e');
      debugPrint('📚 Error stack trace: $stackTrace');
      Logger.error(
        'Error fetching locations',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchFriends(String userId, {String? token, int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/api/social/friends/$userId?page=$page&size=$size';
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch friends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching friends: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(String token, UpdateProfileRequest request) async {
    final endpoint = '${Constants.baseUrl}/users/profile';
    debugPrint('🔄 Updating profile');
    debugPrint('📡 API endpoint: $endpoint');
    
    try {
      // Validate that at least one field is set
      if (!request.hasData) {
        return {
          'success': false,
          'message': 'Không có thông tin nào được cập nhật',
        };
      }

      debugPrint('⏳ Creating multipart request...');
      final uri = Uri.parse(endpoint);
      final multipartRequest = http.MultipartRequest('PUT', uri);
      
      // Add authorization header
      multipartRequest.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔑 Using token: $token');

      // Add text fields
      if (request.displayName != null) {
        multipartRequest.fields['displayName'] = request.displayName!;
        debugPrint('📝 Adding displayName: ${request.displayName}');
      }
      
      if (request.phone != null) {
        multipartRequest.fields['phone'] = request.phone!;
        debugPrint('📱 Adding phone: ${request.phone}');
      }
      
      if (request.bio != null) {
        multipartRequest.fields['bio'] = request.bio!;
        debugPrint('📄 Adding bio: ${request.bio}');
      }
      
      if (request.gender != null) {
        multipartRequest.fields['gender'] = request.gender!;
        debugPrint('👤 Adding gender: ${request.gender}');
      }
      
      if (request.birthday != null) {
        multipartRequest.fields['birthday'] = request.birthday!;
        debugPrint('🎂 Adding birthday: ${request.birthday}');
      }
      
      if (request.location != null) {
        multipartRequest.fields['location'] = request.location!;
        debugPrint('📍 Adding location: ${request.location}');
      }

      // Add avatar file if provided
      if (request.avatarPath != null && request.avatarPath!.isNotEmpty) {
        final avatarFile = File(request.avatarPath!);
        if (await avatarFile.exists()) {
          final mimeType = _getMimeType(request.avatarPath!);
          final avatarMultipart = await http.MultipartFile.fromPath(
            'avatar',
            request.avatarPath!,
            contentType: MediaType.parse(mimeType),
          );
          multipartRequest.files.add(avatarMultipart);
          debugPrint('🖼️ Adding avatar file: ${request.avatarPath}');
        } else {
          debugPrint('⚠️ Avatar file not found: ${request.avatarPath}');
        }
      }

      // Add cover file if provided
      if (request.coverPath != null && request.coverPath!.isNotEmpty) {
        final coverFile = File(request.coverPath!);
        if (await coverFile.exists()) {
          final mimeType = _getMimeType(request.coverPath!);
          final coverMultipart = await http.MultipartFile.fromPath(
            'cover',
            request.coverPath!,
            contentType: MediaType.parse(mimeType),
          );
          multipartRequest.files.add(coverMultipart);
          debugPrint('🖼️ Adding cover file: ${request.coverPath}');
        } else {
          debugPrint('⚠️ Cover file not found: ${request.coverPath}');
        }
      }

      debugPrint('📤 Sending multipart request...');
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('📥 API response status: ${response.statusCode}');
      debugPrint('📄 API response body: ${response.body}');

      Logger.api(
        'PUT',
        endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Profile updated successfully');
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        try {
          final apiResponse = ApiResponse<Profile>.fromJson(
            data,
            (json) => Profile.fromJson(json as Map<String, dynamic>),
          );
          
          if (apiResponse.result == 'SUCCESS') {
            debugPrint('🎉 Successfully updated profile');
            return {
              'success': true,
              'message': apiResponse.message ?? 'Cập nhật thông tin thành công',
              'profile': apiResponse.data,
            };
          } else {
            debugPrint('❌ API returned non-success result');
            return {
              'success': false,
              'message': apiResponse.message ?? 'Cập nhật thông tin thất bại',
            };
          }
        } catch (parseError, parseStack) {
          debugPrint('❌ Error parsing response: $parseError');
          debugPrint('📚 Parse error stack trace: $parseStack');
          return {
            'success': false,
            'message': 'Lỗi xử lý dữ liệu từ server',
          };
        }
      } else if (response.statusCode == 401) {
        debugPrint('🔐 Unauthorized - Token expired');
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          'tokenExpired': true,
        };
      } else if (response.statusCode == 400) {
        debugPrint('⚠️ Bad request');
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': false,
          'message': data['message'] ?? 'Thông tin không hợp lệ',
        };
      } else {
        debugPrint('❌ API request failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Cập nhật thông tin thất bại. Vui lòng thử lại.',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating profile: $e');
      debugPrint('📚 Error stack trace: $stackTrace');
      Logger.error(
        'Error updating profile',
        error: e,
        stackTrace: stackTrace,
      );
      
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

  String _getMimeType(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ========== EDUCATION ==========

  Future<Map<String, dynamic>> addEducation(String token, EducationRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/education';
    return _executeMultipartRequest('POST', endpoint, token, request: request);
  }

  Future<Map<String, dynamic>> updateEducation(String token, int educationId, EducationRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/education/$educationId';
    return _executeMultipartRequest('PUT', endpoint, token, request: request);
  }

  Future<Map<String, dynamic>> deleteEducation(String token, int educationId) async {
    final endpoint = '${Constants.baseUrl}/profiles/education/$educationId';
    return _executeDeleteRequest(endpoint, token, 'education');
  }

  // ========== WORK EXPERIENCE ==========

  Future<Map<String, dynamic>> addWorkExperience(String token, WorkExperienceRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/work-experience';
    return _executeMultipartRequest('POST', endpoint, token, workRequest: request);
  }

  Future<Map<String, dynamic>> updateWorkExperience(String token, int workExperienceId, WorkExperienceRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/work-experience/$workExperienceId';
    return _executeMultipartRequest('PUT', endpoint, token, workRequest: request);
  }

  Future<Map<String, dynamic>> deleteWorkExperience(String token, int workExperienceId) async {
    final endpoint = '${Constants.baseUrl}/profiles/work-experience/$workExperienceId';
    return _executeDeleteRequest(endpoint, token, 'work experience');
  }

  // ========== INTEREST ==========

  Future<Map<String, dynamic>> addInterest(String token, InterestRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/interest';
    return _executeMultipartRequest('POST', endpoint, token, interestRequest: request);
  }

  Future<Map<String, dynamic>> updateInterest(String token, int interestId, InterestRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/interest/$interestId';
    return _executeMultipartRequest('PUT', endpoint, token, interestRequest: request);
  }

  Future<Map<String, dynamic>> deleteInterest(String token, int interestId) async {
    final endpoint = '${Constants.baseUrl}/profiles/interest/$interestId';
    return _executeDeleteRequest(endpoint, token, 'interest');
  }

  // ========== LOCATION ==========

  Future<Map<String, dynamic>> addLocation(String token, LocationRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/location';
    return _executeMultipartRequest('POST', endpoint, token, locationRequest: request);
  }

  Future<Map<String, dynamic>> updateLocation(String token, int locationId, LocationRequest request) async {
    final endpoint = '${Constants.baseUrl}/profiles/location/$locationId';
    return _executeMultipartRequest('PUT', endpoint, token, locationRequest: request);
  }

  Future<Map<String, dynamic>> deleteLocation(String token, int locationId) async {
    final endpoint = '${Constants.baseUrl}/profiles/location/$locationId';
    return _executeDeleteRequest(endpoint, token, 'location');
  }

  // ========== HELPER METHODS ==========

  Future<Map<String, dynamic>> _executeMultipartRequest(
    String method,
    String endpoint,
    String token, {
    EducationRequest? request,
    WorkExperienceRequest? workRequest,
    InterestRequest? interestRequest,
    LocationRequest? locationRequest,
  }) async {
    debugPrint('$method $endpoint');
    
    try {
      final uri = Uri.parse(endpoint);
      final multipartRequest = http.MultipartRequest(method, uri);
      multipartRequest.headers['Authorization'] = 'Bearer $token';

      String? imagePath;

      // Add fields based on request type
      if (request != null) {
        // Education
        if (request.startDate != null) {
          multipartRequest.fields['startDate'] = request.startDate!;
        }
        if (request.endDate != null) {
          multipartRequest.fields['endDate'] = request.endDate!;
        }
        if (request.isCurrent != null) {
          multipartRequest.fields['isCurrent'] = request.isCurrent.toString();
        }
        if (request.description != null) {
          multipartRequest.fields['description'] = request.description!;
        }
        imagePath = request.imagePath;
      } else if (workRequest != null) {
        // Work Experience
        if (workRequest.startDate != null) {
          multipartRequest.fields['startDate'] = workRequest.startDate!;
        }
        if (workRequest.endDate != null) {
          multipartRequest.fields['endDate'] = workRequest.endDate!;
        }
        if (workRequest.isCurrent != null) {
          multipartRequest.fields['isCurrent'] = workRequest.isCurrent.toString();
        }
        if (workRequest.description != null) {
          multipartRequest.fields['description'] = workRequest.description!;
        }
        imagePath = workRequest.imagePath;
      } else if (interestRequest != null) {
        // Interest
        if (interestRequest.name != null) {
          multipartRequest.fields['name'] = interestRequest.name!;
        }
        if (interestRequest.category != null) {
          multipartRequest.fields['category'] = interestRequest.category!;
        }
        if (interestRequest.description != null) {
          multipartRequest.fields['description'] = interestRequest.description!;
        }
        imagePath = interestRequest.imagePath;
      } else if (locationRequest != null) {
        // Location
        if (locationRequest.locationName != null) {
          multipartRequest.fields['locationName'] = locationRequest.locationName!;
        }
        if (locationRequest.locationType != null) {
          multipartRequest.fields['locationType'] = locationRequest.locationType!;
        }
        if (locationRequest.address != null) {
          multipartRequest.fields['address'] = locationRequest.address!;
        }
        if (locationRequest.latitude != null) {
          multipartRequest.fields['latitude'] = locationRequest.latitude.toString();
        }
        if (locationRequest.longitude != null) {
          multipartRequest.fields['longitude'] = locationRequest.longitude.toString();
        }
        if (locationRequest.description != null) {
          multipartRequest.fields['description'] = locationRequest.description!;
        }
        if (locationRequest.isCurrent != null) {
          multipartRequest.fields['isCurrent'] = locationRequest.isCurrent.toString();
        }
        imagePath = locationRequest.imagePath;
      }

      // Add image file if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          final mimeType = _getMimeType(imagePath);
          final imageMultipart = await http.MultipartFile.fromPath(
            'image',
            imagePath,
            contentType: MediaType.parse(mimeType),
          );
          multipartRequest.files.add(imageMultipart);
          debugPrint('🖼️ Adding image file: $imagePath');
        }
      }

      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Không thể kết nối đến server. Vui lòng thử lại sau.');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(data, (json) => json);
        
        if (apiResponse.result == 'SUCCESS') {
          return {
            'success': true,
            'message': apiResponse.message ?? 'Thao tác thành công',
            'data': apiResponse.data,
          };
        } else {
          return {
            'success': false,
            'message': apiResponse.message ?? 'Thao tác thất bại',
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
          'message': data['message'] ?? 'Thông tin không hợp lệ',
        };
      } else {
        return {
          'success': false,
          'message': 'Thao tác thất bại. Vui lòng thử lại.',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      
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

  Future<Map<String, dynamic>> _executeDeleteRequest(String endpoint, String token, String itemType) async {
    debugPrint('🗑️ Deleting $itemType');
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
              'message': apiResponse.message ?? 'Xóa thành công',
            };
          }
        }
        
        return {
          'success': true,
          'message': 'Xóa thành công',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          'tokenExpired': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Không tìm thấy thông tin cần xóa',
        };
      } else {
        return {
          'success': false,
          'message': 'Xóa thất bại. Vui lòng thử lại.',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting $itemType: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      
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