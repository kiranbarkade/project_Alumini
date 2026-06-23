import 'user_model.dart';

class MentorshipModel {
  final String id;
  final dynamic studentId; // Can be a String ID or a UserModel instance
  final dynamic alumniId;  // Can be a String ID or a UserModel instance
  final String topic;
  final DateTime date;
  final String timeSlot;
  final String status;     // 'pending', 'approved', 'rejected', 'completed'
  final String notes;
  final DateTime createdAt;

  MentorshipModel({
    required this.id,
    required this.studentId,
    required this.alumniId,
    required this.topic,
    required this.date,
    required this.timeSlot,
    this.status = 'pending',
    this.notes = '',
    required this.createdAt,
  });

  factory MentorshipModel.fromJson(Map<String, dynamic> json) {
    dynamic studentVal = json['studentId'];
    if (studentVal is Map<String, dynamic>) {
      studentVal = UserModel.fromJson(studentVal);
    }

    dynamic alumniVal = json['alumniId'];
    if (alumniVal is Map<String, dynamic>) {
      alumniVal = UserModel.fromJson(alumniVal);
    }

    return MentorshipModel(
      id: json['_id'] ?? json['id'] ?? '',
      studentId: studentVal,
      alumniId: alumniVal,
      topic: json['topic'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      timeSlot: json['timeSlot'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId is UserModel ? (studentId as UserModel).id : studentId,
      'alumniId': alumniId is UserModel ? (alumniId as UserModel).id : alumniId,
      'topic': topic,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
