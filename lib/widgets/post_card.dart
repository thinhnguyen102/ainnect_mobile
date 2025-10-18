import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/url_helper.dart';
import 'user_avatar.dart';
import '../screens/profile_screen.dart';
import 'media_gallery.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isLiked;
  final VoidCallback onLike;
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
                child: TextButton.icon(
                  onPressed: widget.onLike,
                  icon: Icon(
                    widget.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: widget.isLiked ? Colors.blue : Colors.grey,
                  ),
                  label: Text(
                    'Thích',
                    style: TextStyle(
                      color: widget.isLiked ? Colors.blue : Colors.grey,
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