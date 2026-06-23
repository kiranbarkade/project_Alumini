import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationRepository.getNotifications(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      final updated = await _notificationRepository.markRead(id);
      
      // Update local state list
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsRead(String userId) async {
    try {
      await _notificationRepository.markAllRead(userId);
      
      // Update local state list
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        recipient: n.recipient,
        sender: n.sender,
        type: n.type,
        message: n.message,
        referenceId: n.referenceId,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
