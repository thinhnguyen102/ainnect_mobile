import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_info_request.dart';

class DeviceInfoHelper {
  static const String _deviceIdKey = 'device_id';

  static Future<DeviceInfoRequest> buildDeviceInfo({
    String? deviceId,
    String? location,
    String? userAgentOverride,
  }) async {
    final deviceInfo = DeviceInfoPlugin();
    String? resolvedDeviceName;
    String? resolvedDeviceType;
    String? resolvedOsName;
    String? resolvedOsVersion;
    String? resolvedBrowserName;
    String? resolvedBrowserVersion;
    String? resolvedUserAgent;

    if (kIsWeb) {
      final info = await deviceInfo.webBrowserInfo;
      resolvedDeviceName = info.userAgent ?? info.vendor ?? 'web';
      resolvedDeviceType = 'desktop';
      resolvedOsName = info.platform;
      resolvedOsVersion = info.appVersion;
      resolvedBrowserName = describeEnum(info.browserName);
      resolvedBrowserVersion = info.appVersion;
      resolvedUserAgent = info.userAgent;
    } else if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      resolvedDeviceName = info.model;
      resolvedDeviceType = 'mobile';
      resolvedOsName = 'Android';
      resolvedOsVersion = info.version.release;
      resolvedUserAgent = info.id;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      resolvedDeviceName = info.utsname.machine;
      resolvedDeviceType = 'mobile';
      resolvedOsName = 'iOS';
      resolvedOsVersion = info.systemVersion;
      resolvedUserAgent = info.identifierForVendor;
    } else if (Platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      resolvedDeviceName = info.model;
      resolvedDeviceType = 'desktop';
      resolvedOsName = 'macOS';
      resolvedOsVersion = info.osRelease;
    } else if (Platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      resolvedDeviceName = info.computerName;
      resolvedDeviceType = 'desktop';
      resolvedOsName = 'Windows';
      resolvedOsVersion = info.displayVersion;
    } else if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      resolvedDeviceName = info.name;
      resolvedDeviceType = 'desktop';
      resolvedOsName = 'Linux';
      resolvedOsVersion = info.version;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final resolvedAppVersion = packageInfo.version;
    final resolvedDeviceId = await _getOrCreateDeviceId(deviceId);
    final ua = userAgentOverride ?? resolvedUserAgent ?? _composeUserAgent(
      appVersion: resolvedAppVersion,
      osName: resolvedOsName,
      osVersion: resolvedOsVersion,
      deviceName: resolvedDeviceName,
      browserName: resolvedBrowserName,
      browserVersion: resolvedBrowserVersion,
    );

    return DeviceInfoRequest(
      deviceId: resolvedDeviceId,
      deviceName: resolvedDeviceName,
      deviceType: resolvedDeviceType,
      osName: resolvedOsName,
      osVersion: resolvedOsVersion,
      browserName: resolvedBrowserName,
      browserVersion: resolvedBrowserVersion,
      appVersion: resolvedAppVersion,
      userAgent: ua,
      location: location,
    );
  }

  static Future<String> _getOrCreateDeviceId(String? provided) async {
    if (provided != null && provided.isNotEmpty) {
      return provided;
    }
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _generateRandomId();
    await prefs.setString(_deviceIdKey, generated);
    return generated;
  }

  static String _generateRandomId() {
    final random = Random.secure();
    final millis = DateTime.now().millisecondsSinceEpoch;
    final bytes = List<int>.generate(12, (_) => random.nextInt(256));
    final hex = bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return 'dev-$millis-$hex';
  }

  static String _composeUserAgent({
    String? appVersion,
    String? osName,
    String? osVersion,
    String? deviceName,
    String? browserName,
    String? browserVersion,
  }) {
    final osPart = [osName, osVersion].where((e) => e != null && e.isNotEmpty).join(' ');
    final devicePart = deviceName ?? 'unknown-device';
    final browserPart = [
      browserName,
      if (browserVersion != null && browserVersion.isNotEmpty) browserVersion
    ].where((e) => e != null && e.isNotEmpty).join('/');
    final appPart = appVersion ?? 'unknown';
    final segments = [
      'Ainnect/$appPart',
      '($osPart; $devicePart)',
      if (browserPart.isNotEmpty) browserPart,
    ];
    return segments.where((e) => e.isNotEmpty).join(' ');
  }
}

