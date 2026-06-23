import '../models/notification_model.dart';
import '../services/api_client.dart';

class NotificationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _apiClient.get('/notifications?userId=$userId');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<NotificationModel> markRead(String notificationId) async {
    final response = await _apiClient.put('/notifications/$notificationId/read', {});
    return NotificationModel.fromJson(response['data']);
  }

  Future<void> markAllRead(String userId) async {
    await _apiClient.put('/notifications/read-all', {'userId': userId});
  }
}
