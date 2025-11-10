import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../providers/auth_provider.dart';
import '../services/comment_service.dart';
import '../utils/url_helper.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onDeleted;
  final VoidCallback? onReplied;

  const CommentItem({
    Key? key,
    required this.comment,
    this.onDeleted,
    this.onReplied,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final CommentService _commentService = CommentService();
  bool _showReplies = false;
  bool _showReplyInput = false;
  bool _isLoadingReplies = false;
  List<Comment> _replies = [];
  int _currentPage = 0;
  bool _hasMoreReplies = false;
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;
  bool _isReacting = false;
  
  // Optimistic UI state for reactions
  late bool _currentUserReacted;
  late int _reactionCount;

  @override
  void initState() {
    super.initState();
    _currentUserReacted = widget.comment.currentUserReacted ?? false;
    _reactionCount = widget.comment.reactionCount;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies({bool loadMore = false}) async {
    if (_isLoadingReplies) return;

    setState(() => _isLoadingReplies = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final page = loadMore ? _currentPage + 1 : 0;
      final response = await _commentService.getCommentReplies(
        token,
        widget.comment.id,
        page: page,
        size: 5,
      );

      if (response != null && mounted) {
        setState(() {
          if (loadMore) {
            _replies.addAll(response.comments);
          } else {
            _replies = response.comments;
          }
          _currentPage = response.currentPage;
          _hasMoreReplies = response.hasNext;
          _isLoadingReplies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReplies = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final result = await _commentService.createReply(
        token,
        widget.comment.id,
        _replyController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        _replyController.clear();
        setState(() {
          _showReplyInput = false;
          _showReplies = true;
        });
        _loadReplies(); // Reload replies
        widget.onReplied?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Trả lời thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (result['tokenExpired'] == true) {
          await authProvider.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Trả lời thất bại'),
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _toggleReaction() async {
    if (_isReacting) return;

    // Optimistic UI update
    setState(() {
      _isReacting = true;
      _currentUserReacted = !_currentUserReacted;
      _reactionCount += _currentUserReacted ? 1 : -1;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final result = await _commentService.reactToComment(
        token,
        widget.comment.id,
        'LIKE',
      );

      if (!mounted) return;

      if (!result['success']) {
        // Revert optimistic update on failure
        setState(() {
          _currentUserReacted = !_currentUserReacted;
          _reactionCount += _currentUserReacted ? 1 : -1;
        });

        if (result['tokenExpired'] == true) {
          await authProvider.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Phản ứng thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Revert optimistic update on error
        setState(() {
          _currentUserReacted = !_currentUserReacted;
          _reactionCount += _currentUserReacted ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReacting = false);
      }
    }
  }

  Future<void> _deleteComment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bình luận này?'),
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

    try {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getAccessToken();

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final result = await _commentService.deleteComment(token, widget.comment.id);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onDeleted?.call();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMyComment = authProvider.user?.id == widget.comment.authorId;
    final avatarUrl = widget.comment.authorAvatarUrl != null
        ? UrlHelper.fixImageUrl(widget.comment.authorAvatarUrl!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main comment
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),

            // Comment content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author and content
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.comment.authorDisplayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.comment.content,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Actions
                  Row(
                    children: [
                      // Like button
                      InkWell(
                        onTap: _toggleReaction,
                        child: Row(
                          children: [
                            Icon(
                              _currentUserReacted ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: _currentUserReacted ? Colors.red : Colors.grey[600],
                            ),
                            if (_reactionCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '$_reactionCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _currentUserReacted ? Colors.red : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        timeago.format(DateTime.parse(widget.comment.createdAt), locale: 'vi'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showReplyInput = !_showReplyInput;
                          });
                        },
                        child: Text(
                          'Trả lời',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isMyComment) ...[
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: _deleteComment,
                          child: Text(
                            'Xóa',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Show replies button (only if comment has children)
                  if ((widget.comment.hasChild ?? false) && !_showReplies)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() => _showReplies = true);
                          _loadReplies();
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.comment,
                              size: 14,
                              color: Color(0xFF1E88E5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.comment.replyCount != null && widget.comment.replyCount! > 0
                                  ? 'Xem ${widget.comment.replyCount} phản hồi'
                                  : 'Xem phản hồi',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E88E5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        // Reply input
        if (_showReplyInput)
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Viết câu trả lời...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Color(0xFF1E88E5)),
                  onPressed: _isSubmitting ? null : _submitReply,
                ),
              ],
            ),
          ),

        // Replies list
        if (_showReplies)
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 8),
            child: Column(
              children: [
                if (_isLoadingReplies && _replies.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ..._replies.map((reply) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CommentItem(
                          comment: reply,
                          onDeleted: () {
                            setState(() {
                              _replies.remove(reply);
                            });
                          },
                        ),
                      )),
                if (_hasMoreReplies)
                  TextButton(
                    onPressed: () => _loadReplies(loadMore: true),
                    child: const Text('Xem thêm câu trả lời'),
                  ),
                if (_showReplies && _replies.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showReplies = false;
                        _replies.clear();
                      });
                    },
                    child: const Text('Ẩn câu trả lời'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
