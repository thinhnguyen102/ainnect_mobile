import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/interest_request.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../services/media_upload_service.dart';
import '../services/profile_service.dart';
import '../services/suggestion_service.dart';
import '../utils/url_helper.dart';
import '../widgets/suggestion_fields.dart';

class ManageInterestScreen extends StatefulWidget {
  final Interest? interest;

  const ManageInterestScreen({Key? key, this.interest}) : super(key: key);

  @override
  State<ManageInterestScreen> createState() => _ManageInterestScreenState();
}

class _ManageInterestScreenState extends State<ManageInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final MediaUploadService _mediaUploadService = MediaUploadService();
  final SuggestionService _suggestionService = SuggestionService();

  String? _name;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isFetchingCategories = false;
  List<String> _categoryOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.interest != null) {
      _name = widget.interest!.name;
      _categoryController.text = widget.interest!.category;
      _descriptionController.text = widget.interest!.description ?? '';
      _imageUrl = widget.interest!.imageUrl;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isFetchingCategories = true);
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();
      if (token == null) {
        return;
      }
      final suggestions = await _suggestionService.getInterestCategories(token);
      if (!mounted) return;
      setState(() {
        _categoryOptions = suggestions.map((e) => e.category).toList();
        _isFetchingCategories = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isFetchingCategories = false);
      }
    }
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
    final fixedUrl = UrlHelper.fixImageUrl(_imageUrl);
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
    final normalizedName = _normalize(_name);
    final normalizedCategory = _normalize(_categoryController.text);
    final normalizedDescription = _normalize(_descriptionController.text);

    if (normalizedName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên sở thích'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (normalizedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập danh mục'),
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

      final request = InterestRequest(
        name: normalizedName,
        category: normalizedCategory,
        description: normalizedDescription,
        imageUrl: imageUrl,
      );

      Map<String, dynamic> result;
      if (widget.interest != null) {
        result = await _profileService.updateInterest(token, widget.interest!.id, request);
      } else {
        result = await _profileService.addInterest(token, request);
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
    if (widget.interest == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sở thích này?'),
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
      final result = await _profileService.deleteInterest(token, widget.interest!.id);
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
        title: Text(widget.interest != null ? 'Sửa sở thích' : 'Thêm sở thích'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (widget.interest != null)
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
                        return InterestSuggestionField(
                          token: snapshot.data ?? '',
                          initialValue: _name,
                          onSelected: (value, imageUrl) {
                            setState(() {
                              _name = value;
                              _imageUrl = imageUrl;
                            });
                          },
                          onChanged: (value) => _name = value,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        hintText: 'Ví dụ: Thể thao, Âm nhạc...',
                        prefixIcon: const Icon(Icons.category, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    if (_categoryOptions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categoryOptions.map((category) {
                          final isSelected = _categoryController.text.trim() == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _categoryController.text = category;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_isFetchingCategories)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Mô tả chi tiết về sở thích...',
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

                    ListTile(
                      leading: const Icon(Icons.image, color: Color(0xFF1E88E5)),
                      title: const Text('Ảnh đại diện'),
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
                        widget.interest != null ? 'Cập nhật' : 'Thêm mới',
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

