import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _activeMessages = [];
  bool _isLoading = false;
  String? _error;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get activeMessages => _activeMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConversations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _chatRepository.getConversations(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChatHistory(String userId, String otherUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeMessages = await _chatRepository.getChatHistory(userId, otherUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String senderId, String receiverId, String message) async {
    try {
      final newMessage = await _chatRepository.sendMessage(senderId, receiverId, message);
      _activeMessages.add(newMessage);
      
      // Proactively update/reorder the conversations list in memory
      final idx = _conversations.indexWhere((c) => c.otherUser.id == receiverId);
      if (idx != -1) {
        final existing = _conversations.removeAt(idx);
        _conversations.insert(0, ConversationModel(
          otherUser: existing.otherUser,
          lastMessage: message,
          lastMessageTime: DateTime.now(),
          senderId: senderId
        ));
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void addIncomingMessage(MessageModel message) {
    if (_activeMessages.isNotEmpty && 
        ((message.senderId == _activeMessages.first.senderId && message.receiverId == _activeMessages.first.receiverId) ||
         (message.senderId == _activeMessages.first.receiverId && message.receiverId == _activeMessages.first.senderId))) {
      _activeMessages.add(message);
      notifyListeners();
    }
  }

  void clearActiveMessages() {
    _activeMessages = [];
    notifyListeners();
  }
}
