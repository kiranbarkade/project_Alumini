import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/empty_state_view.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch();
    });
  }

  void _fetch() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final np = Provider.of<NotificationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final currentUser = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (currentUser != null && np.unreadCount > 0)
            TextButton(
              onPressed: () {
                np.markAllNotificationsRead(currentUser.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: np.isLoading
          ? const Center(child: CircularProgressIndicator())
          : np.error != null
              ? Center(child: Text('Error: ${np.error}'))
              : np.notifications.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.notifications_none_outlined,
                      title: 'All caught up!',
                      description: 'We will notify you here when you receive referrals, mentorship updates, or career posts.',
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _fetch(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: np.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = np.notifications[index];
                          return _buildNotificationItem(notif, np, theme);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationItem(dynamic notif, NotificationProvider np, ThemeData theme) {
    IconData leadingIcon;
    Color iconColor;

    switch (notif.type) {
      case 'referral':
        leadingIcon = Icons.shortcut;
        iconColor = Colors.green;
        break;
      case 'mentorship':
        leadingIcon = Icons.calendar_month;
        iconColor = Colors.blue;
        break;
      case 'job':
        leadingIcon = Icons.work;
        iconColor = Colors.orange;
        break;
      default:
        leadingIcon = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }

    final senderName = notif.sender is Map<String, dynamic>
        ? notif.sender['name']
        : notif.sender is dynamic && notif.sender != null && notif.sender.name != null
            ? notif.sender.name
            : 'Alumni Portal System';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notif.isRead 
            ? theme.colorScheme.surface 
            : theme.colorScheme.primaryContainer.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif.isRead 
              ? theme.colorScheme.outlineVariant.withOpacity(0.2) 
              : theme.colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(leadingIcon, color: iconColor, size: 20),
        ),
        title: Text(
          senderName,
          style: TextStyle(
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 13,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif.message,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(notif.createdAt),
              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
            ),
          ],
        ),
        trailing: !notif.isRead
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 20),
                onPressed: () {
                  np.markNotificationRead(notif.id);
                },
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
