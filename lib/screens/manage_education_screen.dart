import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/profile.dart';
import '../models/education_request.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../services/media_upload_service.dart';
import '../widgets/suggestion_fields.dart';
import '../utils/url_helper.dart';

class ManageEducationScreen extends StatefulWidget {
  final Education? education; // null = add new, not null = edit
  final int? userId;

  const ManageEducationScreen({
    Key? key,
    this.education,
    this.userId,
  }) : super(key: key);

  @override
  State<ManageEducationScreen> createState() => _ManageEducationScreenState();
}

class _ManageEducationScreenState extends State<ManageEducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final MediaUploadService _mediaUploadService = MediaUploadService();
  
  String? _schoolName;
  String? _degree;
  String? _fieldOfStudy;
  String? _description;
  String? _startDate;
  String? _endDate;
  bool _isCurrent = false;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Widget _buildRemoteImagePreview() {
    final fixedUrl = UrlHelper.fixImageUrl(_imageUrl);
    if (fixedUrl == null) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
    return Image.network(fixedUrl, height: 200, fit: BoxFit.cover);
  }

  @override
  void initState() {
    super.initState();
    if (widget.education != null) {
      _schoolName = widget.education!.schoolName;
      _degree = widget.education!.degree;
      _fieldOfStudy = widget.education!.fieldOfStudy;
      _description = widget.education!.description;
      _startDate = widget.education!.startDate;
      _endDate = widget.education!.endDate;
      _isCurrent = widget.education!.isCurrent;
      _imageUrl = widget.education!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final initialDate = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (pickedDate != null) {
      final formattedDate = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartDate) {
          _startDate = formattedDate;
        } else {
          _endDate = formattedDate;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final normalizedSchoolName = _normalize(_schoolName);
    if (normalizedSchoolName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên trường học'),
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

      final normalizedDegree = _normalize(_degree);
      final normalizedFieldOfStudy = _normalize(_fieldOfStudy);
      final normalizedDescription = _normalize(_description);

      // Build description with all info
      final descriptionParts = <String>[];
      if (normalizedDegree != null) descriptionParts.add('Bằng: $normalizedDegree');
      if (normalizedFieldOfStudy != null) descriptionParts.add('Chuyên ngành: $normalizedFieldOfStudy');
      if (normalizedDescription != null) descriptionParts.add(normalizedDescription);
      final fullDescription = [
        normalizedSchoolName,
        if (descriptionParts.isNotEmpty) descriptionParts.join('\n'),
      ].whereType<String>().join('\n');

      if (_imageFile != null && !_mediaUploadService.isAvailable) {
        throw Exception(_mediaUploadService.errorMessage ??
            'Upload media chưa được cấu hình');
      }

      String? uploadUrl = _imageUrl;
      if (_imageFile != null) {
        uploadUrl = await _mediaUploadService.uploadFile(_imageFile!);
      }

      final request = EducationRequest(
        schoolName: normalizedSchoolName,
        degree: normalizedDegree,
        fieldOfStudy: normalizedFieldOfStudy,
        startDate: _startDate,
        endDate: _isCurrent ? null : _endDate,
        isCurrent: _isCurrent,
        description: fullDescription.isEmpty ? null : fullDescription,
        imageUrl: uploadUrl,
      );

      Map<String, dynamic> result;
      if (widget.education != null) {
        // Update
        result = await _profileService.updateEducation(token, widget.education!.id, request);
      } else {
        // Add new
        result = await _profileService.addEducation(token, request);
      }

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lưu thành công'),
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
              content: Text(result['message'] ?? 'Lưu thất bại'),
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

  Future<void> _delete() async {
    if (widget.education == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa học vấn này?'),
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

      final result = await _profileService.deleteEducation(token, widget.education!.id);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (result['tokenExpired'] == true) {
          await authProvider.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Xóa thất bại'),
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
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.education != null ? 'Sửa học vấn' : 'Thêm học vấn'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (widget.education != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<String?>(
              future: authProvider.getAccessToken(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final token = snapshot.data ?? '';
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // School name with suggestion
                        SchoolSuggestionField(
                          token: token,
                          initialValue: _schoolName,
                          onSelected: (schoolName, imageUrl) {
                            setState(() {
                              _schoolName = schoolName;
                              _imageUrl = imageUrl;
                            });
                          },
                          onChanged: (value) => _schoolName = value,
                        ),

                    const SizedBox(height: 16),

                    // Degree
                    TextFormField(
                      initialValue: _degree,
                      decoration: InputDecoration(
                        labelText: 'Bằng cấp',
                        hintText: 'VD: Cử nhân, Thạc sĩ, Tiến sĩ',
                        prefixIcon: const Icon(Icons.school, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      onChanged: (value) => _degree = value,
                    ),

                    const SizedBox(height: 16),

                    // Field of study
                    TextFormField(
                      initialValue: _fieldOfStudy,
                      decoration: InputDecoration(
                        labelText: 'Chuyên ngành',
                        hintText: 'VD: Công nghệ thông tin',
                        prefixIcon: const Icon(Icons.book, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      onChanged: (value) => _fieldOfStudy = value,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      initialValue: _description,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Thông tin thêm về học vấn...',
                        prefixIcon: const Icon(Icons.description, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      onChanged: (value) => _description = value,
                    ),

                    const SizedBox(height: 16),

                    // Start date
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Color(0xFF1E88E5)),
                      title: const Text('Ngày bắt đầu'),
                      subtitle: Text(_startDate ?? 'Chưa chọn'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onTap: () => _pickDate(context, true),
                    ),

                    const SizedBox(height: 16),

                    // Current checkbox
                    CheckboxListTile(
                      value: _isCurrent,
                      onChanged: (value) {
                        setState(() {
                          _isCurrent = value ?? false;
                          if (_isCurrent) _endDate = null;
                        });
                      },
                      title: const Text('Đang học tại đây'),
                      activeColor: const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),

                    if (!_isCurrent) ...[
                      const SizedBox(height: 16),
                      // End date
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Color(0xFF1E88E5)),
                        title: const Text('Ngày kết thúc'),
                        subtitle: Text(_endDate ?? 'Chưa chọn'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        onTap: () => _pickDate(context, false),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Image picker
                    ListTile(
                      leading: const Icon(Icons.image, color: Color(0xFF1E88E5)),
                      title: const Text('Ảnh trường học'),
                      subtitle: Text(_imageFile != null 
                          ? 'Đã chọn ảnh'
                          : _imageUrl != null 
                              ? 'Có ảnh từ gợi ý'
                              : 'Chưa có ảnh'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onTap: _pickImage,
                    ),

                    if (_imageFile != null || _imageUrl != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _imageFile != null
                            ? Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
                            : _buildRemoteImagePreview(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Save button
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
                        widget.education != null ? 'Cập nhật' : 'Thêm mới',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
              },
            ),
    );
  }
}
