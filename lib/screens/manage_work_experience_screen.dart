import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/profile.dart';
import '../models/work_experience_request.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../widgets/suggestion_fields.dart';

class ManageWorkExperienceScreen extends StatefulWidget {
  final WorkExperience? workExperience;

  const ManageWorkExperienceScreen({
    Key? key,
    this.workExperience,
  }) : super(key: key);

  @override
  State<ManageWorkExperienceScreen> createState() => _ManageWorkExperienceScreenState();
}

class _ManageWorkExperienceScreenState extends State<ManageWorkExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  
  String? _companyName;
  String? _position;
  String? _location;
  String? _description;
  String? _startDate;
  String? _endDate;
  bool _isCurrent = false;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workExperience != null) {
      _companyName = widget.workExperience!.companyName;
      _position = widget.workExperience!.position;
      _location = widget.workExperience!.location;
      _description = widget.workExperience!.description;
      _startDate = widget.workExperience!.startDate;
      _endDate = widget.workExperience!.endDate;
      _isCurrent = widget.workExperience!.isCurrent;
      _imageUrl = widget.workExperience!.imageUrl;
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

    if (_companyName == null || _companyName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên công ty'),
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

      // Build description
      final descriptionParts = <String>[];
      if (_companyName != null) descriptionParts.add('Công ty: $_companyName');
      if (_position != null) descriptionParts.add('Vị trí: $_position');
      if (_location != null) descriptionParts.add('Địa điểm: $_location');
      if (_description != null) descriptionParts.add(_description!);
      
      final fullDescription = descriptionParts.join('\n');

      final request = WorkExperienceRequest(
        startDate: _startDate,
        endDate: _isCurrent ? null : _endDate,
        isCurrent: _isCurrent,
        description: fullDescription,
        imagePath: _imageFile?.path,
      );

      Map<String, dynamic> result;
      if (widget.workExperience != null) {
        result = await _profileService.updateWorkExperience(token, widget.workExperience!.id, request);
      } else {
        result = await _profileService.addWorkExperience(token, request);
      }

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lưu thành công'),
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
    if (widget.workExperience == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa kinh nghiệm làm việc này?'),
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

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final result = await _profileService.deleteWorkExperience(token, widget.workExperience!.id);

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
        title: Text(widget.workExperience != null ? 'Sửa kinh nghiệm' : 'Thêm kinh nghiệm'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (widget.workExperience != null)
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
                        // Company name with suggestion
                        CompanySuggestionField(
                          token: token,
                          initialValue: _companyName,
                          onSelected: (companyName, imageUrl) {
                            setState(() {
                              _companyName = companyName;
                              _imageUrl = imageUrl;
                            });
                          },
                        ),

                    const SizedBox(height: 16),

                    // Position
                    TextFormField(
                      initialValue: _position,
                      decoration: InputDecoration(
                        labelText: 'Vị trí',
                        hintText: 'VD: Software Engineer, Manager',
                        prefixIcon: const Icon(Icons.work, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      onChanged: (value) => _position = value,
                    ),

                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      initialValue: _location,
                      decoration: InputDecoration(
                        labelText: 'Địa điểm',
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
                      onChanged: (value) => _location = value,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      initialValue: _description,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả công việc',
                        hintText: 'Mô tả chi tiết về công việc...',
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
                      title: const Text('Đang làm việc tại đây'),
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
                      title: const Text('Logo công ty'),
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
                            : Image.network(_imageUrl!, height: 200, fit: BoxFit.cover),
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
                        widget.workExperience != null ? 'Cập nhật' : 'Thêm mới',
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
