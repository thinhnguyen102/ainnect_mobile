class DeviceResponse {
  final int? id;
  final int? userId;
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
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final DateTime? deletedAt;

  const DeviceResponse({
    this.id,
    this.userId,
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
    this.createdAt,
    this.lastActiveAt,
    this.deletedAt,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceResponse(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
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
      isTrusted: json['isTrusted'] as bool?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.tryParse(json['lastActiveAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.tryParse(json['deletedAt']) : null,
    );
  }
}

