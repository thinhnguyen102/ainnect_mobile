import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../utils/url_helper.dart';
import '../screens/profile_screen.dart';
import '../providers/auth_provider.dart';

class CommentBottomSheet extends StatefulWidget {
  final Post post;

  const CommentBottomSheet({super.key, required this.post});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
        _comments.clear();
      }
    });

    try {
      final response = await _postService.getPostComments(widget.post.id, page: _currentPage);
      setState(() {
        _comments.addAll(response.comments);
        _currentPage++;
        _totalPages = response.totalPages;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải bình luận: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) {
        _loadComments();
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Lấy token từ AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng đăng nhập để bình luận.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      final success = await _postService.addComment(
        token,
        widget.post.id,
        content,
      );

      if (success) {
        // Hiển thị ngay comment vừa gửi lên đầu danh sách
        final user = authProvider.user;
        if (user != null) {
          final now = DateTime.now().toIso8601String();
          setState(() {
            _comments.insert(0, Comment(
              id: -1, // id tạm thời, server sẽ trả id thật khi reload
              postId: widget.post.id,
              authorId: user.id,
              authorUsername: user.username,
              authorDisplayName: user.displayName,
              authorAvatarUrl: user.avatarUrl,
              parentId: null,
              content: content,
              reactionCount: 0,
              createdAt: now,
              updatedAt: now,
            ));
          });
        }
        _commentController.clear();
        _focusNode.unfocus();
        // Không cần await _loadComments(refresh: true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể đăng bình luận. Vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: \\${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Bình luận',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadComments(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _comments.length + (_isLoading || !_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _comments.length) {
                    final comment = _comments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: comment.authorId),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF6366F1),
                      backgroundImage: comment.authorAvatarUrl != null
                          ? NetworkImage(UrlHelper.fixImageUrl(comment.authorAvatarUrl!))
                          : null,
                      child: comment.authorAvatarUrl == null
                          ? Text(
                              comment.authorDisplayName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(userId: comment.authorId),
                            ),
                          );
                        },
                        child: Text(
                          comment.authorDisplayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                                      const SizedBox(height: 4),
                                      Text(comment.content),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        comment.createdAt,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      if (comment.reactionCount > 0)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.thumb_up,
                                              size: 14,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${comment.reactionCount}',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (_isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!_hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Không còn bình luận nào để tải',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Viết bình luận...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1877F2),
                  ),
                  child: IconButton(
                    onPressed: _submitComment,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
