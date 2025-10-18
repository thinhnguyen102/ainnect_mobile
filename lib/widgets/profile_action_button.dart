import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileActionButton extends StatelessWidget {
  final Profile profile;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onAddFriend;
  final VoidCallback? onFollow;
  final VoidCallback? onMessage;

  const ProfileActionButton({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.onEdit,
    this.onAddFriend,
    this.onFollow,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return ElevatedButton(
        onPressed: onEdit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 40),
        ),
        child: const Text('Chỉnh sửa trang cá nhân'),
      );
    }

    return Row(
      children: [
        if (profile.relationship.canSendFriendRequest)
          Expanded(
            child: ElevatedButton(
              onPressed: onAddFriend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                minimumSize: const Size(0, 40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  Text('Kết bạn'),
                ],
              ),
            ),
          ),
        if (!profile.relationship.friend && !profile.relationship.canSendFriendRequest)
          Expanded(
            child: ElevatedButton(
              onPressed: onFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: profile.relationship.following ? Colors.grey[200] : const Color(0xFF1877F2),
                foregroundColor: profile.relationship.following ? Colors.black : Colors.white,
                minimumSize: const Size(0, 40),
              ),
              child: Text(profile.relationship.following ? 'Đang theo dõi' : 'Theo dõi'),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: onMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              minimumSize: const Size(0, 40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.message),
                SizedBox(width: 8),
                Text('Nhắn tin'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
