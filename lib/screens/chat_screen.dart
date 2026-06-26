import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/user_model.dart';
import '../providers/alumni_provider.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;

  const ChatScreen({super.key, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _refreshTimer;

  UserModel? _otherUser;

  @override
  void initState() {
    super.initState();
    _loadChat();
    // Periodic refresh every 1 second (MVP approach)
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<ChatProvider>(context, listen: false)
            .fetchChatHistory(auth.currentUser!.id, widget.otherUserId);
      }
    });
  }

  @override
  void dispose() {
    // Cancel the periodic refresh timer to avoid leaks.
    _refreshTimer?.cancel();
    // Clear any active chat messages when leaving the screen.
    Provider.of<ChatProvider>(context, listen: false).clearActiveMessages();
    // Dispose controllers.
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChat() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final alumniProvider = Provider.of<AlumniProvider>(context, listen: false);

    if (auth.currentUser == null) return;
    
    // Fetch chat messages
    chat.fetchChatHistory(auth.currentUser!.id, widget.otherUserId);

    // Fetch details of the other user to render title
    try {
      // Check if they are in the available users list
      final cachedUser = auth.availableUsers.firstWhere(
        (u) => u.id == widget.otherUserId,
      );
      setState(() {
        _otherUser = cachedUser;
      });
    } catch (_) {
      // Query from repository via alumniProvider
      await alumniProvider.fetchAlumnusById(widget.otherUserId);
      if (alumniProvider.selectedAlumnus != null && mounted) {
        setState(() {
          _otherUser = alumniProvider.selectedAlumnus;
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);

    if (auth.currentUser == null) return;

    _messageController.clear();
    final success = await chat.sendMessage(
      auth.currentUser!.id,
      widget.otherUserId,
      text,
    );

    if (success) {
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(chat.error ?? 'Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    final currentUser = auth.currentUser;

int receivedCount = chat.activeMessages.where((msg) => msg.senderId == widget.otherUserId).length;

return Scaffold(
  appBar: AppBar(
    title: _otherUser == null
        ? const Text('Chat')
        : Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: _otherUser!.profileImage.isNotEmpty
                    ? NetworkImage(_otherUser!.profileImage)
                    : null,
                child: _otherUser!.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _otherUser!.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_otherUser!.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$receivedCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _otherUser!.company.isNotEmpty
                          ? '${_otherUser!.designation} at ${_otherUser!.company}'
                          : _otherUser!.branch,
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: chat.isLoading && chat.activeMessages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.activeMessages.length,
                    itemBuilder: (context, index) {
                      final msg = chat.activeMessages[index];
                      final isMe = msg.senderId == currentUser?.id;

                      // Trigger scroll to bottom on load
                      if (index == chat.activeMessages.length - 1) {
                        _scrollToBottom();
                      }

                      return _buildMessageBubble(msg, isMe, theme);
                    },
                  ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe, ThemeData theme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: TextStyle(
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.createdAt),
              style: TextStyle(
                color: isMe 
                    ? Colors.white.withOpacity(0.7) 
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
