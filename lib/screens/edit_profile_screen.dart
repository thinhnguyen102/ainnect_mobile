import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/update_profile_request.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../services/media_upload_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final MediaUploadService _mediaUploadService = MediaUploadService();
  
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String? _gender;
  DateTime? _birthday;
  File? _avatarFile;
  File? _coverFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    if (user != null) {
      setState(() {
        _displayNameController.text = user.displayName ?? '';
        _phoneController.text = user.phone ?? '';
        _bioController.text = user.bio ?? '';
        _gender = user.gender;
        if (user.birthday != null) {
          try {
            _birthday = DateTime.parse(user.birthday!);
          } catch (e) {
            debugPrint('Error parsing birthday: $e');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAvatar) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        if (isAvatar) {
          _avatarFile = File(pickedFile.path);
        } else {
          _coverFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickBirthday() async {
    final initialDate = _birthday ?? DateTime(2000, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthday = pickedDate;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Format birthday as yyyy-MM-dd
      String? birthdayStr;
      if (_birthday != null) {
        birthdayStr = '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}';
      }

      String? avatarUrl;
      if (_avatarFile != null) {
        if (!_mediaUploadService.isAvailable) {
          throw Exception(_mediaUploadService.errorMessage ??
              'Upload media chưa được cấu hình');
        }
        debugPrint('☁️ Uploading avatar via R2...');
        avatarUrl = await _mediaUploadService.uploadFile(_avatarFile!);
      }

      String? coverUrl;
      if (_coverFile != null) {
        if (!_mediaUploadService.isAvailable) {
          throw Exception(_mediaUploadService.errorMessage ??
              'Upload media chưa được cấu hình');
        }
        debugPrint('☁️ Uploading cover via R2...');
        coverUrl = await _mediaUploadService.uploadFile(_coverFile!);
      }

      final request = UpdateProfileRequest(
        displayName: _displayNameController.text.isNotEmpty ? _displayNameController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        gender: _gender,
        birthday: birthdayStr,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        avatarUrl: avatarUrl,
        coverUrl: coverUrl,
      );

      final result = await _profileService.updateProfile(token, request);

      if (!mounted) return;

      if (result['success']) {
        // Update user in AuthProvider
        await authProvider.refreshUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Cập nhật thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        if (result['tokenExpired'] == true) {
          // Token expired, logout
          await authProvider.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Cập nhật thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa trang cá nhân'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
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
                    // Cover Photo
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        image: _coverFile != null
                            ? DecorationImage(
                                image: FileImage(_coverFile!),
                                fit: BoxFit.cover,
                              )
                            : user?.coverUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(user!.coverUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton.small(
                              heroTag: 'cover',
                              onPressed: () => _pickImage(false),
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.camera_alt, color: Color(0xFF1E88E5)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _avatarFile != null
                                ? FileImage(_avatarFile!)
                                : user?.avatarUrl != null
                                    ? NetworkImage(user!.avatarUrl!)
                                    : null,
                            child: (_avatarFile == null && user?.avatarUrl == null)
                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: FloatingActionButton.small(
                              heroTag: 'avatar',
                              onPressed: () => _pickImage(true),
                              backgroundColor: const Color(0xFF1E88E5),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Display Name
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên hiển thị',
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên hiển thị';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: const Icon(Icons.phone, color: Color(0xFF1E88E5)),
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

                    // Bio
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Giới thiệu bản thân',
                        hintText: 'Viết vài dòng về bạn...',
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

                    // Gender
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: 'Giới tính',
                        prefixIcon: const Icon(Icons.wc, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'MALE', child: Text('Nam')),
                        DropdownMenuItem(value: 'FEMALE', child: Text('Nữ')),
                        DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Birthday
                    ListTile(
                      leading: const Icon(Icons.cake, color: Color(0xFF1E88E5)),
                      title: const Text('Ngày sinh'),
                      subtitle: Text(
                        _birthday != null
                            ? '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}'
                            : 'Chưa chọn',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onTap: _pickBirthday,
                    ),

                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Nơi ở hiện tại',
                        hintText: 'VD: Hà Nội, Việt Nam',
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
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
                      child: const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
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
