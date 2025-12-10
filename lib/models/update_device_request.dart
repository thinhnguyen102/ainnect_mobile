class UpdateDeviceRequest {
  final String? deviceName;
  final bool? isTrusted;
  final bool? isActive;
  final String? location;

  const UpdateDeviceRequest({
    this.deviceName,
    this.isTrusted,
    this.isActive,
    this.location,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'deviceName': deviceName,
      'isTrusted': isTrusted,
      'isActive': isActive,
      'location': location,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

