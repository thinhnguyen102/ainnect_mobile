import 'package:flutter/material.dart';
import '../services/group_service.dart';
import 'package:provider/provider.dart';
import 'package:ainnect/providers/auth_provider.dart'; // Added import for AuthProvider
import 'package:ainnect/models/post.dart'; // Import Post model
import 'package:ainnect/widgets/post_card.dart'; // Import PostCard widget

class GroupDetailScreen extends StatefulWidget {
  final int groupId;

  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Future<Map<String, dynamic>>? _groupFuture;
  Future<Map<String, dynamic>>? _postsFuture;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authToken = await authProvider.getAccessToken();
    
    if (authToken != null) {
      setState(() {
        _groupFuture = GroupService().fetchGroupDetail(widget.groupId, token: authToken);
        _postsFuture = GroupService().fetchGroupPosts(groupId: widget.groupId, token: authToken);
      });
    }
  }

  Widget _buildPostsList(List<dynamic> posts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = Post.fromJson(posts[index]);
        return PostCard(
          post: post,
          isLiked: post.reactions.currentUserReacted,
          onLike: ([type]) {
            // Handle like action
          },
          onComment: () {
            // Handle comment action
          },
          onShare: () {
            // Handle share action
          },
        );
      },
    );
  }

  Widget _buildCreatePostSection() {
    final TextEditingController _postController = TextEditingController();
    final List<String> _selectedMedia = [];
    String _visibility = 'public_';

    void _pickMedia() async {
      // Implement media picker logic here
    }

    void _createPost() async {
      final authToken = await Provider.of<AuthProvider>(context, listen: false).token;
      if (authToken != null) {
        try {
          await GroupService().createGroupPost(
            groupId: widget.groupId,
            content: _postController.text,
            visibility: _visibility,
            mediaFiles: _selectedMedia,
            token: authToken,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng bài viết thành công!')),
          );
          _postController.clear();
          setState(() {
            _postsFuture = GroupService().fetchGroupPosts(groupId: widget.groupId, token: authToken);
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể đăng bài viết: $e')),
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo bài viết',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _postController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Chia sẻ suy nghĩ của bạn...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _visibility,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1)),
                    items: const [
                      DropdownMenuItem(
                        value: 'public_',
                        child: Row(
                          children: [
                            Icon(Icons.public, size: 18, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Text('Công khai'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'private_',
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, size: 18, color: Color(0xFFEF4444)),
                            SizedBox(width: 8),
                            Text('Riêng tư'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _visibility = value;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.send, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Đăng',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }  Widget _buildJoinGroupButton() {
    Future<void> _joinGroup() async {
      final authToken = await Provider.of<AuthProvider>(context, listen: false).token;
      if (authToken != null) {
        try {
          final response = await GroupService().joinGroup(
            groupId: widget.groupId,
            token: authToken,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          setState(() {
            _groupFuture = GroupService().fetchGroupDetail(widget.groupId, token: authToken);
            _postsFuture = GroupService().fetchGroupPosts(groupId: widget.groupId, token: authToken);
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tham gia nhóm: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _joinGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_add, size: 22),
              SizedBox(width: 8),
              Text(
                'Tham gia nhóm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveGroupButton() {
    Future<void> _leaveGroup() async {
      final authToken = await Provider.of<AuthProvider>(context, listen: false).token;
      if (authToken != null) {
        try {
          final response = await GroupService().leaveGroup(
            groupId: widget.groupId,
            token: authToken,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          setState(() {
            _groupFuture = GroupService().fetchGroupDetail(widget.groupId, token: authToken);
            _postsFuture = GroupService().fetchGroupPosts(groupId: widget.groupId, token: authToken);
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể rời nhóm: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _leaveGroup,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.exit_to_app, size: 22),
              SizedBox(width: 8),
              Text(
                'Rời khỏi nhóm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Chi tiết nhóm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: _groupFuture == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            )
          : FutureBuilder<Map<String, dynamic>>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            );
          } else if (snapshot.hasError) {
            if (snapshot.error.toString().contains('400')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bạn chưa phải là thành viên của nhóm này',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final group = snapshot.data!['data'];
            final isMember = group['isMember'] ?? false;
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image with Group Name
                  Stack(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        child: Image.network(
                          group['coverUrl'].toString().replaceFirst('localhost', '10.0.2.2'),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF1E88E5),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.group,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: group['privacy'] == 'public_'
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        group['privacy'] == 'public_'
                                            ? Icons.public
                                            : Icons.lock_outline,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        group['privacy'] == 'public_'
                                            ? 'Công khai'
                                            : 'Riêng tư',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.people_outline,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${group['memberCount']} thành viên',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Group Info
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giới thiệu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          group['description'] ?? 'Không có mô tả',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.person_outline,
                          'Quản trị viên',
                          group['ownerDisplayName'] ?? 'Unknown',
                        ),
                      ],
                    ),
                  ),
                  
                  // Join/Leave Button
                  if (!isMember)
                    _buildJoinGroupButton()
                  else
                    _buildLeaveGroupButton(),
                  
                  // Create Post Section (only for members)
                  if (isMember) ...[
                    const SizedBox(height: 8),
                    _buildCreatePostSection(),
                  ],
                  
                  // Posts Section
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Bài viết',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  
                  FutureBuilder<Map<String, dynamic>>(
                    future: _postsFuture,
                    builder: (context, postSnapshot) {
                      if (postSnapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        );
                      } else if (postSnapshot.hasError) {
                        if (postSnapshot.error.toString().contains('400')) {
                          return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tham gia nhóm để xem bài viết',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Không thể tải bài viết',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      } else if (postSnapshot.hasData) {
                        final posts = postSnapshot.data!['content'];
                        if (posts.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Chưa có bài viết nào',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return _buildPostsList(posts);
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Không tìm thấy bài viết',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy thông tin nhóm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}