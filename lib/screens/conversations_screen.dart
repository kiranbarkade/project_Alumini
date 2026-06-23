import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state_view.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  void _loadConversations() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      Provider.of<ChatProvider>(context, listen: false).fetchConversations(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Direct Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadConversations(),
              child: chat.isLoading && chat.conversations.isEmpty
                  ? LoadingShimmer.cardList()
                  : chat.error != null
                      ? EmptyStateView(
                          icon: Icons.error_outline,
                          title: 'Failed to load messages',
                          description: chat.error!,
                          actionText: 'Retry',
                          onActionPressed: _loadConversations,
                        )
                      : chat.conversations.isEmpty
                          ? const EmptyStateView(
                              icon: Icons.forum_outlined,
                              title: 'No Conversations',
                              description: 'Find students or alumni in the Directory to start a chat!',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: chat.conversations.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
                              itemBuilder: (context, index) {
                                final conv = chat.conversations[index];
                                final isVerified = conv.otherUser.isVerified;
                                final hasLogo = conv.otherUser.company.isNotEmpty;
                                
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 26,
                                    backgroundImage: conv.otherUser.profileImage.isNotEmpty
                                        ? NetworkImage(conv.otherUser.profileImage)
                                        : null,
                                    child: conv.otherUser.profileImage.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        conv.otherUser.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (isVerified) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        hasLogo 
                                            ? '${conv.otherUser.designation} at ${conv.otherUser.company}'
                                            : conv.otherUser.branch,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        conv.lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    _formatTime(conv.lastMessageTime),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                                    ),
                                  ),
                                  onTap: () {
                                    context.push('/chat/${conv.otherUser.id}');
                                  },
                                );
                              },
                            ),
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      // return hour/minute
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }
}
