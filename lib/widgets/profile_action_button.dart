import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../models/friendship_models.dart';
import '../providers/friendship_provider.dart';

class ProfileActionButton extends StatefulWidget {
  final Profile profile;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onAddFriend;
  final VoidCallback? onFollow;
  final VoidCallback? onMessage;
  final VoidCallback? onLogout;

  const ProfileActionButton({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.onEdit,
    this.onAddFriend,
    this.onFollow,
    this.onMessage,
    this.onLogout,
  });

  @override
  State<ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<ProfileActionButton> {
  @override
  void initState() {
    super.initState();
    if (!widget.isCurrentUser) {
      // Load social stats when widget initializes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FriendshipProvider>().loadSocialStats(widget.profile.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCurrentUser) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: widget.onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Chỉnh sửa trang cá nhân'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: widget.onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[700],
              minimumSize: const Size(double.infinity, 40),
              side: BorderSide(color: Colors.red[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout_outlined),
                SizedBox(width: 8),
                Text('Đăng xuất'),
              ],
            ),
          ),
        ],
      );
    }

    return Consumer<FriendshipProvider>(
      builder: (context, friendshipProvider, child) {
        final stats = friendshipProvider.getSocialStats(widget.profile.userId);
        final isFriend = stats?.friend ?? false;
        final canSendRequest = stats?.canSendFriendRequest ?? true;
        final isFollowing = stats?.following ?? false;
        final friendsCount = stats?.friendsCount ?? 0;

        return Column(
          children: [
            Row(
              children: [
                // Friend/Add Friend Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isFriend
                        ? null // Already friends, disabled
                        : canSendRequest
                            ? widget.onAddFriend
                            : null, // Can't send request (maybe pending)
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFriend
                          ? Colors.green[100]
                          : canSendRequest
                              ? const Color(0xFF1877F2)
                              : Colors.grey[300],
                      foregroundColor: isFriend
                          ? Colors.green[700]
                          : canSendRequest
                              ? Colors.white
                              : Colors.grey[700],
                      minimumSize: const Size(0, 40),
                      disabledBackgroundColor: isFriend
                          ? Colors.green[100]
                          : Colors.grey[300],
                      disabledForegroundColor: isFriend
                          ? Colors.green[700]
                          : Colors.grey[700],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFriend
                              ? Icons.check_circle
                              : canSendRequest
                                  ? Icons.person_add
                                  : Icons.access_time,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isFriend
                                ? 'Bạn bè'
                                : canSendRequest
                                    ? 'Kết bạn'
                                    : 'Đã gửi',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Message Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: widget.onMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Icon(Icons.message, size: 20),
                  ),
                ),
              ],
            ),
            // Friends count
            if (friendsCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$friendsCount bạn bè',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
