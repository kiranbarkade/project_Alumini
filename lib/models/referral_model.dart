import 'user_model.dart';
import 'job_model.dart';

class ReferralModel {
  final String id;
  final dynamic studentId; // Can be a String ID or a UserModel instance
  final dynamic alumniId;  // Can be a String ID or a UserModel instance
  final dynamic jobId;     // Can be a String ID or a JobModel instance (Optional)
  final String companyName;
  final String jobTitle;
  final String message;
  final String status;     // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  ReferralModel({
    required this.id,
    required this.studentId,
    required this.alumniId,
    this.jobId,
    this.companyName = '',
    this.jobTitle = '',
    required this.message,
    this.status = 'pending',
    required this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    dynamic studentVal = json['studentId'];
    if (studentVal is Map<String, dynamic>) {
      studentVal = UserModel.fromJson(studentVal);
    }

    dynamic alumniVal = json['alumniId'];
    if (alumniVal is Map<String, dynamic>) {
      alumniVal = UserModel.fromJson(alumniVal);
    }

    dynamic jobVal = json['jobId'];
    if (jobVal != null && jobVal is Map<String, dynamic>) {
      jobVal = JobModel.fromJson(jobVal);
    }

    return ReferralModel(
      id: json['_id'] ?? json['id'] ?? '',
      studentId: studentVal,
      alumniId: alumniVal,
      jobId: jobVal,
      companyName: json['companyName'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
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
      if (jobId != null) 'jobId': jobId is JobModel ? (jobId as JobModel).id : jobId,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
