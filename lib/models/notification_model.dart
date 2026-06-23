import 'user_model.dart';

class NotificationModel {
  final String id;
  final String recipient; // User ID
  final dynamic sender;   // UserModel or String ID
  final String type;     // 'referral', 'mentorship', 'job', 'post', 'system'
  final String message;
  final String referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    required this.sender,
    required this.type,
    required this.message,
    this.referenceId = '',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    dynamic senderVal = json['sender'];
    if (senderVal is Map<String, dynamic>) {
      senderVal = UserModel.fromJson(senderVal);
    }

    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      recipient: json['recipient'] ?? '',
      sender: senderVal,
      type: json['type'] ?? 'system',
      message: json['message'] ?? '',
      referenceId: json['referenceId'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipient': recipient,
      'sender': sender is UserModel ? (sender as UserModel).id : sender,
      'type': type,
      'message': message,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
