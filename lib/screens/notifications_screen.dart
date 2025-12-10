import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/notification_provider.dart';
import '../models/notification_models.dart';
import '../utils/url_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshNotifications();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<NotificationProvider>().refreshNotifications();
  }

  void _markAllAsRead() async {
    await context.read<NotificationProvider>().markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả là đã đọc'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Đánh dấu đã đọc',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            );
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông báo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn sẽ nhận được thông báo ở đây',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF6366F1),
            child: Column(
              children: [
                // Stats header
                if (provider.stats != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.notifications,
                          label: 'Tất cả',
                          value: provider.stats!.totalCount.toString(),
                        ),
                        _StatItem(
                          icon: Icons.mark_email_unread,
                          label: 'Chưa đọc',
                          value: provider.stats!.unreadCount.toString(),
                          color: const Color(0xFF6366F1),
                        ),
                        _StatItem(
                          icon: Icons.today,
                          label: 'Hôm nay',
                          value: provider.stats!.todayCount.toString(),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                
                // Notifications list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = provider.notifications[index];
                      return _NotificationItem(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDismiss: () => _deleteNotification(notification.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationResponse notification) async {
    // Mark as read
    if (!notification.isRead) {
      await context.read<NotificationProvider>().markAsRead(notification.id);
    }
    
    // Navigate based on notification type and target
    // TODO: Implement navigation based on targetType and targetId
    if (notification.targetType == 'POST' && notification.targetId != null) {
      // Navigate to post detail
    } else if (notification.targetType == 'USER' && notification.targetId != null) {
      // Navigate to user profile
    }
  }

  void _deleteNotification(int notificationId) async {
    await context.read<NotificationProvider>().deleteNotification(notificationId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa thông báo'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.grey[700]!;
    
    return Column(
      children: [
        Icon(
          icon,
          color: effectiveColor,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationResponse notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: notification.isRead ? Colors.white : const Color(0xFFF3F4F6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Actor avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.typeDisplayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF1F2937),
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(notification.createdAt, locale: 'vi'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (notification.actor?.avatarUrl != null) {
      return FutureBuilder<Map<String, String>>(
        future: UrlHelper.getHeaders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
            );
          }
          
          final resolvedUrl = UrlHelper.fixImageUrl(notification.actor!.avatarUrl);
          if (resolvedUrl == null) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTypeColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(),
                color: Colors.white,
                size: 24,
              ),
            );
          }

          return CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: NetworkImage(
              resolvedUrl,
              headers: snapshot.data,
            ),
          );
        },
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getTypeColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
      case NotificationType.reply:
        return Icons.comment;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.unfollow:
        return Icons.person_remove;
      case NotificationType.friendRequest:
      case NotificationType.friendAccept:
        return Icons.group;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.share:
        return Icons.share;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.groupInvite:
      case NotificationType.groupJoin:
        return Icons.group_add;
      case NotificationType.postModeration:
        return Icons.gavel;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.like:
        return const Color(0xFFEF4444);
      case NotificationType.comment:
      case NotificationType.reply:
        return const Color(0xFF3B82F6);
      case NotificationType.follow:
        return const Color(0xFF10B981);
      case NotificationType.unfollow:
        return const Color(0xFF6B7280);
      case NotificationType.friendRequest:
      case NotificationType.friendAccept:
        return const Color(0xFF1E88E5);
      case NotificationType.mention:
        return const Color(0xFF06B6D4);
      case NotificationType.share:
        return const Color(0xFFF59E0B);
      case NotificationType.message:
        return const Color(0xFF6366F1);
      case NotificationType.groupInvite:
      case NotificationType.groupJoin:
        return const Color(0xFFEC4899);
      case NotificationType.postModeration:
        return const Color(0xFFF97316);
      case NotificationType.system:
        return const Color(0xFF6B7280);
    }
  }
}
