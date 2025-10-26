import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/url_helper.dart';
import 'user_avatar.dart';
import '../screens/profile_screen.dart';
import 'media_gallery.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isLiked;
  final void Function([String? reactionType]) onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Map<String, dynamic>? get _currentUserReaction {
    final type = widget.post.reactions.currentUserReactionType?.toUpperCase();
    if (type == null) return null;
    return _reactions.firstWhere(
      (r) => r['type'] == type,
      orElse: () => _reactions[0],
    );
  }
  OverlayEntry? _reactionOverlay;
  bool _isHoveringLike = false;

  final List<Map<String, dynamic>> _reactions = [
    {'type': 'LIKE', 'icon': Icons.thumb_up, 'color': Colors.blue},
    {'type': 'LOVE', 'icon': Icons.favorite, 'color': Colors.pink},
    {'type': 'HAHA', 'icon': Icons.emoji_emotions, 'color': Colors.amber},
    {'type': 'WOW', 'icon': Icons.emoji_objects, 'color': Colors.orange},
    {'type': 'SAD', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.blueGrey},
    {'type': 'ANGRY', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
  ];

  void _showReactionOverlay(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    _reactionOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeReactionOverlay,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy - 60,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _reactions.map((reaction) {
                      return GestureDetector(
                        onTap: () {
                          _removeReactionOverlay();
                          widget.onLike(reaction['type']);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            reaction['icon'],
                            color: reaction['color'],
                            size: 32,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_reactionOverlay!);
  }

  void _removeReactionOverlay() {
    _reactionOverlay?.remove();
    _reactionOverlay = null;
  }

  @override
  void dispose() {
    _removeReactionOverlay();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: widget.post.authorId),
                      ),
                    );
                  },
                  child: UserAvatar(
                    avatarUrl: widget.post.authorAvatarUrl,
                    displayName: widget.post.authorDisplayName,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(userId: widget.post.authorId),
                              ),
                            );
                          },
                          child: Text(
                            widget.post.authorDisplayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      Text(
                        widget.post.createdAt,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    // TODO: Show post options
                  },
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post.content,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Media
          if (widget.post.media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: MediaGallery(media: widget.post.media),
            ),

          // Stats
          if (widget.post.reactions.totalCount > 0 || widget.post.commentCount > 0)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (widget.post.reactions.totalCount > 0) ...[
                    const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.reactions.totalCount}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                  if (widget.post.commentCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.commentCount} bình luận',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                  if (widget.post.shareCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.shareCount} chia sẻ',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),

          const Divider(height: 1),

          // Actions
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    _showReactionOverlay(context);
                  },
                  child: TextButton.icon(
                    onPressed: () => widget.onLike(),
                    icon: _currentUserReaction != null
                        ? Icon(
                            _currentUserReaction!['icon'],
                            color: _currentUserReaction!['color'],
                          )
                        : Icon(
                            Icons.thumb_up_outlined,
                            color: Colors.grey,
                          ),
                    label: Text(
                      _currentUserReaction != null
                          ? _currentUserReaction!['type'].substring(0, 1) + _currentUserReaction!['type'].substring(1).toLowerCase()
                          : 'Thích',
                      style: TextStyle(
                        color: _currentUserReaction != null
                            ? _currentUserReaction!['color']
                            : Colors.grey,
                        fontWeight: _currentUserReaction != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onComment,
                  icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                  label: const Text(
                    'Bình luận',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onShare,
                  icon: const Icon(Icons.share_outlined, color: Colors.grey),
                  label: const Text(
                    'Chia sẻ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}