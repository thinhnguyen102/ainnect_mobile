import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../utils/url_helper.dart';

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
      final success = await _postService.addComment(
        'YOUR_AUTH_TOKEN', // TODO: Get actual auth token
        widget.post.id,
        content,
      );

      if (success) {
        _commentController.clear();
        await _loadComments(refresh: true);
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bình luận'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadComments(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _comments.length + (_isLoading || !_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _comments.length) {
                    final comment = _comments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.authorDisplayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.content),
                                  const SizedBox(height: 4),
                                  Row(
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
                                        Text(
                                          '${comment.reactionCount} thích',
                                          style: TextStyle(
                                            color: Colors.grey[600],
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
          Container(
            padding: const EdgeInsets.all(8),
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
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Viết bình luận...',
                        border: OutlineInputBorder(),
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
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _submitComment,
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
