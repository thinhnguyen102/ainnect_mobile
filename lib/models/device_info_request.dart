class DeviceInfoRequest {
  final String? deviceId;
  final String? deviceName;
  final String? deviceType;
  final String? osName;
  final String? osVersion;
  final String? browserName;
  final String? browserVersion;
  final String? appVersion;
  final String? userAgent;
  final String? location;
  final bool? isTrusted;
  final bool? isActive;

  const DeviceInfoRequest({
    this.deviceId,
    this.deviceName,
    this.deviceType,
    this.osName,
    this.osVersion,
    this.browserName,
    this.browserVersion,
    this.appVersion,
    this.userAgent,
    this.location,
    this.isTrusted,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'osName': osName,
      'osVersion': osVersion,
      'browserName': browserName,
      'browserVersion': browserVersion,
      'appVersion': appVersion,
      'userAgent': userAgent,
      'location': location,
      'isTrusted': isTrusted,
      'isActive': isActive,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

