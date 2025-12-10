import 'device_info_request.dart';

class RegisterDeviceRequest {
  final DeviceInfoRequest device;

  const RegisterDeviceRequest(this.device);

  Map<String, dynamic> toJson() => device.toJson();
}

