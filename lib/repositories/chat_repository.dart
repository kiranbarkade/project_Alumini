import '../models/message_model.dart';
import '../services/api_client.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<ConversationModel>> getConversations(String userId) async {
    final response = await _apiClient.get('/messages/conversations/$userId');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => ConversationModel.fromJson(json)).toList();
  }

  Future<List<MessageModel>> getChatHistory(String userId, String otherUserId) async {
    final response = await _apiClient.get('/messages/history/$userId/$otherUserId');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => MessageModel.fromJson(json)).toList();
  }

  Future<MessageModel> sendMessage(String senderId, String receiverId, String message) async {
    final response = await _apiClient.post('/messages', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    });
    return MessageModel.fromJson(response['data']);
  }
}
