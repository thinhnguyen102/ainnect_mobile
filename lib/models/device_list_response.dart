import 'device_response.dart';

class DeviceListResponse {
  final List<DeviceResponse> devices;
  final int? total;
  final int? activeCount;
  final int? trustedCount;

  const DeviceListResponse({
    required this.devices,
    this.total,
    this.activeCount,
    this.trustedCount,
  });

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['devices'] as List<dynamic>? ?? [])
        .map((e) => DeviceResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    return DeviceListResponse(
      devices: list,
      total: json['total'] as int?,
      activeCount: json['activeCount'] as int?,
      trustedCount: json['trustedCount'] as int?,
    );
  }
}

