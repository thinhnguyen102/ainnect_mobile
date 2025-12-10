// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  usernameOrEmail: json['usernameOrEmail'] as String,
  password: json['password'] as String,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceType: json['deviceType'] as String?,
      osName: json['osName'] as String?,
      osVersion: json['osVersion'] as String?,
      browserName: json['browserName'] as String?,
      browserVersion: json['browserVersion'] as String?,
      appVersion: json['appVersion'] as String?,
      userAgent: json['userAgent'] as String?,
      location: json['location'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'usernameOrEmail': instance.usernameOrEmail,
      'password': instance.password,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'deviceType': instance.deviceType,
      'osName': instance.osName,
      'osVersion': instance.osVersion,
      'browserName': instance.browserName,
      'browserVersion': instance.browserVersion,
      'appVersion': instance.appVersion,
      'userAgent': instance.userAgent,
      'location': instance.location,
    };
