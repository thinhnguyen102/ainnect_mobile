import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/suggestion_models.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class SuggestionService {
  Future<List<SchoolSuggestion>> suggestSchools(String token, String query, {int limit = 10}) async {
    final endpoint = '${Constants.baseUrl}/suggestions/schools?q=$query&limit=$limit';
    debugPrint('🔍 Suggesting schools for query: $query');
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
        final apiResponse = ApiResponse<SuggestionResponse<SchoolSuggestion>>.fromJson(
          data,
          (json) => SuggestionResponse.fromJson(
            json as Map<String, dynamic>,
            (itemJson) => SchoolSuggestion.fromJson(itemJson),
          ),
        );
        
        if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
          debugPrint('✅ Got ${apiResponse.data!.suggestions.length} school suggestions');
          return apiResponse.data!.suggestions;
        }
      }
      
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error suggesting schools: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error suggesting schools', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<CompanySuggestion>> suggestCompanies(String token, String query, {int limit = 10}) async {
    final endpoint = '${Constants.baseUrl}/suggestions/companies?q=$query&limit=$limit';
    debugPrint('🔍 Suggesting companies for query: $query');
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
        final apiResponse = ApiResponse<SuggestionResponse<CompanySuggestion>>.fromJson(
          data,
          (json) => SuggestionResponse.fromJson(
            json as Map<String, dynamic>,
            (itemJson) => CompanySuggestion.fromJson(itemJson),
          ),
        );
        
        if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
          debugPrint('✅ Got ${apiResponse.data!.suggestions.length} company suggestions');
          return apiResponse.data!.suggestions;
        }
      }
      
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error suggesting companies: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error suggesting companies', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<InterestSuggestion>> suggestInterests(String token, String query, {int limit = 10}) async {
    final endpoint = '${Constants.baseUrl}/suggestions/interests?q=$query&limit=$limit';
    debugPrint('🔍 Suggesting interests for query: $query');
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
        final apiResponse = ApiResponse<SuggestionResponse<InterestSuggestion>>.fromJson(
          data,
          (json) => SuggestionResponse.fromJson(
            json as Map<String, dynamic>,
            (itemJson) => InterestSuggestion.fromJson(itemJson),
          ),
        );
        
        if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
          debugPrint('✅ Got ${apiResponse.data!.suggestions.length} interest suggestions');
          return apiResponse.data!.suggestions;
        }
      }
      
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error suggesting interests: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error suggesting interests', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<LocationSuggestion>> suggestLocations(String token, String query, {int limit = 10}) async {
    final endpoint = '${Constants.baseUrl}/suggestions/locations?q=$query&limit=$limit';
    debugPrint('🔍 Suggesting locations for query: $query');
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
        final apiResponse = ApiResponse<SuggestionResponse<LocationSuggestion>>.fromJson(
          data,
          (json) => SuggestionResponse.fromJson(
            json as Map<String, dynamic>,
            (itemJson) => LocationSuggestion.fromJson(itemJson),
          ),
        );
        
        if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
          debugPrint('✅ Got ${apiResponse.data!.suggestions.length} location suggestions');
          return apiResponse.data!.suggestions;
        }
      }
      
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error suggesting locations: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error suggesting locations', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<CategorySuggestion>> getInterestCategories(String token) async {
    final endpoint = '${Constants.baseUrl}/suggestions/interest-categories';
    debugPrint('🔍 Getting interest categories');
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
        final apiResponse = ApiResponse<SuggestionResponse<CategorySuggestion>>.fromJson(
          data,
          (json) => SuggestionResponse.fromJson(
            json as Map<String, dynamic>,
            (itemJson) => CategorySuggestion.fromJson(itemJson),
          ),
        );
        
        if (apiResponse.result == 'SUCCESS' && apiResponse.data != null) {
          debugPrint('✅ Got ${apiResponse.data!.suggestions.length} categories');
          return apiResponse.data!.suggestions;
        }
      }
      
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting categories: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      Logger.error('Error getting categories', error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
