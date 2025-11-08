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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
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
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      avatarUrl: widget.post.authorAvatarUrl,
                      displayName: widget.post.authorDisplayName,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.post.createdAt,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.public,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, size: 22),
                    color: Colors.grey[700],
                    onPressed: () {
                      // TODO: Show post options
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF374151),
                ),
              ),
            ),

          // Media
          if (widget.post.media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MediaGallery(media: widget.post.media),
              ),
            ),

          // Stats
          if (widget.post.reactions.totalCount > 0 || widget.post.commentCount > 0 || widget.post.shareCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  if (widget.post.reactions.totalCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.thumb_up,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.post.reactions.totalCount}',
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (widget.post.commentCount > 0) ...[
                    Text(
                      '${widget.post.commentCount} bình luận',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (widget.post.shareCount > 0) ...[
                    if (widget.post.commentCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Text(
                      '${widget.post.shareCount} chia sẻ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          if (widget.post.reactions.totalCount > 0 || widget.post.commentCount > 0 || widget.post.shareCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      _showReactionOverlay(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _currentUserReaction != null
                            ? _currentUserReaction!['color'].withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: TextButton.icon(
                        onPressed: () => widget.onLike(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: _currentUserReaction != null
                            ? Icon(
                                _currentUserReaction!['icon'],
                                color: _currentUserReaction!['color'],
                                size: 22,
                              )
                            : Icon(
                                Icons.thumb_up_outlined,
                                color: Colors.grey[700],
                                size: 22,
                              ),
                        label: Text(
                          _currentUserReaction != null
                              ? _currentUserReaction!['type'].substring(0, 1) + 
                                _currentUserReaction!['type'].substring(1).toLowerCase()
                              : 'Thích',
                          style: TextStyle(
                            color: _currentUserReaction != null
                                ? _currentUserReaction!['color']
                                : Colors.grey[700],
                            fontWeight: _currentUserReaction != null 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextButton.icon(
                      onPressed: widget.onComment,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey[700],
                        size: 22,
                      ),
                      label: Text(
                        'Bình luận',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextButton.icon(
                      onPressed: widget.onShare,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.share_outlined,
                        color: Colors.grey[700],
                        size: 22,
                      ),
                      label: Text(
                        'Chia sẻ',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
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