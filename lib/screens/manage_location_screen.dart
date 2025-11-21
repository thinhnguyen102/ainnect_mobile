import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/location_request.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../services/media_upload_service.dart';
import '../services/profile_service.dart';
import '../utils/url_helper.dart';
import '../widgets/suggestion_fields.dart';

class ManageLocationScreen extends StatefulWidget {
  final UserLocation? location;

  const ManageLocationScreen({Key? key, this.location}) : super(key: key);

  @override
  State<ManageLocationScreen> createState() => _ManageLocationScreenState();
}

class _ManageLocationScreenState extends State<ManageLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final MediaUploadService _mediaUploadService = MediaUploadService();

  String? _locationName;
  final TextEditingController _locationTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  bool _isCurrent = false;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      final location = widget.location!;
      _locationName = location.locationName;
      _locationTypeController.text = location.locationType;
      _addressController.text = location.address;
      _descriptionController.text = location.description ?? '';
      _latitudeController.text = location.latitude?.toString() ?? '';
      _longitudeController.text = location.longitude?.toString() ?? '';
      _isCurrent = location.isCurrent;
      _imageUrl = location.imageUrl;
    }
  }

  @override
  void dispose() {
    _locationTypeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseCoordinate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _imageFile = File(file.path);
      });
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _imageFile!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    final fixedUrl = UrlHelper.fixImageUrl(_imageUrl);
    if (fixedUrl == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        fixedUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final normalizedName = _normalize(_locationName);
    final normalizedType = _normalize(_locationTypeController.text);
    final normalizedAddress = _normalize(_addressController.text);
    final normalizedDescription = _normalize(_descriptionController.text);
    final latitude = _parseCoordinate(_latitudeController.text);
    final longitude = _parseCoordinate(_longitudeController.text);

    if (normalizedName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên địa điểm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (normalizedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập loại địa điểm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (normalizedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      String? imageUrl = _imageUrl;
      if (_imageFile != null) {
        if (!_mediaUploadService.isAvailable) {
          throw Exception(
            _mediaUploadService.errorMessage ?? 'Upload media chưa được cấu hình.',
          );
        }
        imageUrl = await _mediaUploadService.uploadFile(_imageFile!);
      }

      final request = LocationRequest(
        locationName: normalizedName,
        locationType: normalizedType,
        address: normalizedAddress,
        latitude: latitude,
        longitude: longitude,
        description: normalizedDescription,
        isCurrent: _isCurrent,
        imageUrl: imageUrl,
      );

      Map<String, dynamic> result;
      if (widget.location != null) {
        result = await _profileService.updateLocation(token, widget.location!.id, request);
      } else {
        result = await _profileService.addLocation(token, request);
      }

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lưu thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lưu thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.location == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa địa điểm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }
      final result = await _profileService.deleteLocation(token, widget.location!.id);
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Xóa thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location != null ? 'Sửa địa điểm' : 'Thêm địa điểm'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (widget.location != null)
            IconButton(
              onPressed: _isLoading ? null : _delete,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder<String?>(
                      future: context.read<AuthProvider>().getAccessToken(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return LocationSuggestionField(
                          token: snapshot.data ?? '',
                          initialValue: _locationName,
                          onSelected: (value, imageUrl) {
                            setState(() {
                              _locationName = value;
                              _imageUrl = imageUrl;
                            });
                          },
                          onChanged: (value) => _locationName = value,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationTypeController,
                      decoration: InputDecoration(
                        labelText: 'Loại địa điểm',
                        hintText: 'Ví dụ: current, hometown...',
                        prefixIcon: const Icon(Icons.label, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ',
                        prefixIcon: const Icon(Icons.location_city, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SwitchListTile(
                      value: _isCurrent,
                      onChanged: (value) => setState(() => _isCurrent = value),
                      title: const Text('Địa điểm hiện tại'),
                      activeThumbColor: const Color(0xFF1E88E5),
                      activeTrackColor: const Color(0x661E88E5),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Thông tin thêm về địa điểm...',
                        prefixIcon: const Icon(Icons.description, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Vĩ độ (Latitude)',
                              prefixIcon: const Icon(Icons.explore, color: Color(0xFF1E88E5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Kinh độ (Longitude)',
                              prefixIcon: const Icon(Icons.public, color: Color(0xFF1E88E5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ListTile(
                      leading: const Icon(Icons.image, color: Color(0xFF1E88E5)),
                      title: const Text('Ảnh địa điểm'),
                      subtitle: Text(_imageFile != null
                          ? 'Đã chọn ảnh từ thiết bị'
                          : _imageUrl != null
                              ? 'Đang sử dụng ảnh hiện tại'
                              : 'Chưa chọn ảnh'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onTap: _pickImage,
                    ),

                    const SizedBox(height: 12),
                    _buildImagePreview(),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.location != null ? 'Cập nhật' : 'Thêm mới',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

