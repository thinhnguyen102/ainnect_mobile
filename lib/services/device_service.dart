import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_info_request.dart';
import '../models/device_response.dart';
import '../models/update_device_request.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class DeviceService {
  static const String _tokenKey = 'auth_token';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<DeviceResponse>> getUserDevices() async {
    final endpoint = '${Constants.baseUrl}/devices';
    final headers = await _getHeaders();
    Logger.request('GET', endpoint, headers: headers);
    final response = await http.get(Uri.parse(endpoint), headers: headers);
    Logger.response('GET', endpoint, response.statusCode, body: response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['devices'] as List<dynamic>? ?? data as List<dynamic>;
      return list.map((e) => DeviceResponse.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load devices');
  }

  Future<DeviceResponse> getDevice(int id) async {
    final endpoint = '${Constants.baseUrl}/devices/$id';
    final headers = await _getHeaders();
    Logger.request('GET', endpoint, headers: headers);
    final response = await http.get(Uri.parse(endpoint), headers: headers);
    Logger.response('GET', endpoint, response.statusCode, body: response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return DeviceResponse.fromJson(data);
    }
    throw Exception('Failed to load device');
  }

  Future<void> updateDevice(int id, UpdateDeviceRequest request) async {
    final endpoint = '${Constants.baseUrl}/devices/$id';
    final headers = await _getHeaders();
    final body = jsonEncode(request.toJson());
    Logger.request('PUT', endpoint, headers: headers, body: body);
    final response = await http.put(Uri.parse(endpoint), headers: headers, body: body);
    Logger.response('PUT', endpoint, response.statusCode, body: response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update device');
    }
  }

  Future<void> deleteDevice(int id) async {
    final endpoint = '${Constants.baseUrl}/devices/$id';
    final headers = await _getHeaders();
    Logger.request('DELETE', endpoint, headers: headers);
    final response = await http.delete(Uri.parse(endpoint), headers: headers);
    Logger.response('DELETE', endpoint, response.statusCode, body: response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete device');
    }
  }

  Future<void> logoutDevice(int id) async {
    final endpoint = '${Constants.baseUrl}/devices/$id/logout';
    final headers = await _getHeaders();
    Logger.request('POST', endpoint, headers: headers);
    final response = await http.post(Uri.parse(endpoint), headers: headers);
    Logger.response('POST', endpoint, response.statusCode, body: response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to logout device');
    }
  }

  Future<void> logoutAllDevices() async {
    final endpoint = '${Constants.baseUrl}/devices/logout-all';
    final headers = await _getHeaders();
    Logger.request('POST', endpoint, headers: headers);
    final response = await http.post(Uri.parse(endpoint), headers: headers);
    Logger.response('POST', endpoint, response.statusCode, body: response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to logout all devices');
    }
  }

  Future<void> trustDevice(int id) async {
    final endpoint = '${Constants.baseUrl}/devices/$id/trust';
    final headers = await _getHeaders();
    Logger.request('POST', endpoint, headers: headers);
    final response = await http.post(Uri.parse(endpoint), headers: headers);
    Logger.response('POST', endpoint, response.statusCode, body: response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to trust device');
    }
  }

  Future<void> untrustDevice(int id) async {
    final endpoint = '${Constants.baseUrl}/devices/$id/untrust';
    final headers = await _getHeaders();
    Logger.request('POST', endpoint, headers: headers);
    final response = await http.post(Uri.parse(endpoint), headers: headers);
    Logger.response('POST', endpoint, response.statusCode, body: response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to untrust device');
    }
  }

  Future<void> registerOrUpdate(DeviceInfoRequest request) async {
    final endpoint = '${Constants.baseUrl}/devices';
    final headers = await _getHeaders();
    final body = jsonEncode(request.toJson());
    Logger.request('POST', endpoint, headers: headers, body: body);
    final response = await http.post(Uri.parse(endpoint), headers: headers, body: body);
    Logger.response('POST', endpoint, response.statusCode, body: response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to register device');
    }
  }
}

