import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/create_post_request.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../services/websocket_service.dart';
import '../widgets/user_avatar.dart';
import '../widgets/media_preview.dart';
import '../widgets/bottom_nav_bar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _postService = PostService();
  final _imagePicker = ImagePicker();
  final _websocketService = WebSocketService();
  List<String> _selectedMedia = [];
  List<String> _mediaTypes = []; // Track media type (image/video)
  String _visibility = 'public_';
  bool _isLoading = false;
  StreamSubscription? _wsSubscription;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.id;
    
    if (_currentUserId != null) {
      // Ensure WebSocket is connected
      if (!_websocketService.isConnected) {
        await _websocketService.connect();
      }
      
      // Subscribe to post updates for current user
      _websocketService.subscribeToUserPosts(_currentUserId!);
      
      // Listen to notification stream
      _wsSubscription = _websocketService.notificationStream.listen((data) {
        if (mounted && data['type'] != null) {
          _handlePostNotification(data);
        }
      });
    }
  }

  void _handlePostNotification(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    
    if (type == 'POST_UPDATED') {
      // Media processing completed successfully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Bài viết của bạn đã được đăng thành công!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else if (type == 'POST_UPDATE_FAILED') {
      // Media processing failed
      final error = notification['error'] as String?;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi xử lý bài viết: ${error ?? "Vui lòng thử lại"}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _wsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            _selectedMedia.add(image.path);
            _mediaTypes.add('image');
          }
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

  Future<void> _pickVideo() async {
    try {
      final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedMedia.add(video.path);
          _mediaTypes.add('video');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn video: $e'),
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
          content: Text('Vui lòng nhập nội dung hoặc chọn ảnh/video'),
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

      print('Creating post with ${_selectedMedia.length} media files');
      print('Content: ${_contentController.text.trim()}');
      print('Visibility: $_visibility');

      final request = CreatePostRequest(
        content: _contentController.text.trim(),
        visibility: _visibility,
        mediaFiles: _selectedMedia,
      );

      // Gửi request và nhận response ngay lập tức (HTTP 201)
      // Backend sẽ xử lý media ở background và gửi thông báo qua WebSocket
      final post = await _postService.createPost(token, request);

      if (post != null && mounted) {
        print('✅ Post created successfully! Post ID: ${post.id}');
        print('   Content: ${post.content}');
        print('   Media count: ${post.media.length}');
        print('   Visibility: ${post.visibility}');
        
        // Bài viết đã được tạo thành công (có thể chưa có media)
        final hasMedia = _selectedMedia.isNotEmpty;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasMedia 
                ? '📤 Bài viết đang được xử lý. Media sẽ xuất hiện sau ít phút!'
                : '✅ Đăng bài viết thành công!',
            ),
            backgroundColor: hasMedia ? const Color(0xFF6366F1) : const Color(0xFF10B981),
            duration: Duration(seconds: hasMedia ? 4 : 2),
          ),
        );
        
        // Quay về home screen ngay lập tức
        Navigator.pop(context, true);
      } else if (mounted) {
        print('❌ Post creation returned null!');

        // Lỗi khi tạo bài viết
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đăng bài viết. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error creating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng bài: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
            child: Padding(
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
                        final mediaType = _mediaTypes[index];
                        return Stack(
                          children: [
                            MediaPreview(
                              mediaUrl: file.path,
                              mediaType: mediaType,
                              onRemove: () {
                                setState(() {
                                  _selectedMedia.removeAt(index);
                                  _mediaTypes.removeAt(index);
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
                        onPressed: _isLoading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Thêm ảnh'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _pickVideo,
                        icon: const Icon(Icons.videocam),
                        label: const Text('Thêm video'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Đăng bài', style: TextStyle(color: Colors.white)),
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
