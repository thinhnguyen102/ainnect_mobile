import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class ProfileService {
  Future<Profile?> getProfile(String token, int userId, {int page = 0, int size = 10}) async {
    final endpoint = '${Constants.baseUrl}/profiles/$userId?page=$page&size=$size';
    debugPrint('🔍 Fetching profile for userId: $userId, page: $page, size: $size');
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
      debugPrint('❌ Error fetching profile: $e');
      debugPrint('📚 Error stack trace: $stackTrace');
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
}