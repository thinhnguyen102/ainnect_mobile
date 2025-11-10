import 'package:flutter/material.dart';
import '../models/messaging_models.dart';

class MessageReactionPicker extends StatelessWidget {
  final Function(ReactionType) onReactionSelected;

  const MessageReactionPicker({
    Key? key,
    required this.onReactionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReactionType.values.map((reaction) {
          return InkWell(
            onTap: () => onReactionSelected(reaction),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                _getReactionEmoji(reaction),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getReactionEmoji(ReactionType reaction) {
    switch (reaction) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.haha:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
    }
  }
}

class MessageReactionDisplay extends StatelessWidget {
  final Map<String, int>? reactionCounts;
  final String? currentUserReaction;
  final Function(ReactionType) onReactionTap;
  final VoidCallback onReactionLongPress;

  const MessageReactionDisplay({
    Key? key,
    required this.reactionCounts,
    required this.currentUserReaction,
    required this.onReactionTap,
    required this.onReactionLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reactionCounts == null || reactionCounts!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter out reactions with count 0
    final activeReactions = reactionCounts!.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (activeReactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: activeReactions.map((entry) {
          final reactionType = _parseReactionType(entry.key);
          final count = entry.value;
          final isCurrentUser = currentUserReaction?.toLowerCase() == entry.key.toLowerCase();

          return GestureDetector(
            onTap: () => onReactionTap(reactionType),
            onLongPress: onReactionLongPress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? const Color(0xFF1E88E5).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentUser 
                      ? const Color(0xFF1E88E5)
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getReactionEmoji(reactionType),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (count > 1) ...[
                    const SizedBox(width: 4),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentUser ? const Color(0xFF1E88E5) : Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  ReactionType _parseReactionType(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return ReactionType.like;
      case 'love':
        return ReactionType.love;
      case 'haha':
        return ReactionType.haha;
      case 'wow':
        return ReactionType.wow;
      case 'sad':
        return ReactionType.sad;
      case 'angry':
        return ReactionType.angry;
      default:
        return ReactionType.like;
    }
  }

  String _getReactionEmoji(ReactionType reaction) {
    switch (reaction) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.haha:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
    }
  }
}
