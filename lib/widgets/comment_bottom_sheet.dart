import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';
import 'comment_item.dart';

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
    debugPrint('💬 CommentBottomSheet initState for post: ${widget.post.id}');
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

    debugPrint('💬 Loading comments for post ${widget.post.id}, page: $_currentPage, refresh: $refresh');

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
        _comments.clear();
      }
    });

    try {
      debugPrint('💬 Calling API: /comments/by-post/${widget.post.id}?page=$_currentPage&size=4');
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();
      final response = await _postService.getPostComments(
        token!,
        widget.post.id, 
        page: _currentPage,
        size: 4, // Use size 4 as per API specification
      );
      
      debugPrint('💬 API Response: ${response.comments.length} comments, hasNext: ${response.hasNext}');
      
      if (mounted) {
        setState(() {
          _comments.addAll(response.comments);
          _currentPage++;
          _totalPages = response.totalPages;
          _hasMore = response.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

    final authProvider = context.read<AuthProvider>();
    final token = await authProvider.getAccessToken();
    
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để bình luận'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _postService.addComment(
        token,
        widget.post.id,
        content,
      );

      if (success) {
        _commentController.clear();
        _focusNode.unfocus();
        await _loadComments(refresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đăng bình luận'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
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
            content: Text('Lỗi: ${e.toString()}'),
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
              child: _comments.isEmpty && !_isLoading
                  ? const Center(
                      child: Text(
                        'Chưa có bình luận nào.\nHãy là người đầu tiên bình luận!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _comments.length + (_isLoading || !_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _comments.length) {
                          final comment = _comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CommentItem(
                              comment: comment,
                              onDeleted: () {
                                setState(() {
                                  _comments.removeAt(index);
                                });
                              },
                              onReplied: () {
                                // Optionally refresh to update reply count
                                _loadComments(refresh: true);
                              },
                            ),
                          );
                        }
                        if (_isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (!_hasMore && _comments.isNotEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'Đã tải hết bình luận',
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
