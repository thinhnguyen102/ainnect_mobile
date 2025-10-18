import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/create_post_request.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../widgets/user_avatar.dart';
import '../widgets/media_preview.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _postService = PostService();
  final _imagePicker = ImagePicker();
  List<String> _selectedMedia = [];
  String _visibility = 'public_';
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images != null) {
        setState(() {
          _selectedMedia.addAll(images.map((image) => image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung hoặc chọn ảnh'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      final request = CreatePostRequest(
        content: _contentController.text.trim(),
        visibility: _visibility,
        mediaFiles: _selectedMedia,
      );

      final post = await _postService.createPost(token, request);

      if (post != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng bài viết thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đăng bài viết'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng bài: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài viết'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Đăng',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(
              child: Text('Vui lòng đăng nhập để đăng bài'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User info
                Row(
                  children: [
                    UserAvatar(
                      avatarUrl: user.avatarUrl,
                      displayName: user.displayName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButton<String>(
                            value: _visibility,
                            isDense: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'public_',
                                child: Row(
                                  children: [
                                    Icon(Icons.public, size: 16),
                                    SizedBox(width: 8),
                                    Text('Công khai'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'friends_',
                                child: Row(
                                  children: [
                                    Icon(Icons.people, size: 16),
                                    SizedBox(width: 8),
                                    Text('Bạn bè'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'private_',
                                child: Row(
                                  children: [
                                    Icon(Icons.lock, size: 16),
                                    SizedBox(width: 8),
                                    Text('Chỉ mình tôi'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _visibility = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Content
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Bạn đang nghĩ gì?',
                    border: InputBorder.none,
                  ),
                ),

                // Media preview
                if (_selectedMedia.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedMedia.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final file = File(_selectedMedia[index]);
                        return Stack(
                          children: [
                            MediaPreview(
                              mediaUrl: file.path,
                              mediaType: 'image',
                              onRemove: () {
                                setState(() {
                                  _selectedMedia.removeAt(index);
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Thêm ảnh'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: Implement video upload
                        },
                        icon: const Icon(Icons.videocam),
                        label: const Text('Thêm video'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
