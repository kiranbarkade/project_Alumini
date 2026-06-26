//assigned by Shasitya

import 'user_model.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // 'fulltime', 'internship', 'referral', 'event'
  final String description;
  final dynamic postedBy; // Can be a String ID or a UserModel instance
  final List<String> skillsRequired;
  final String salary;
  final String experienceRequired;
  final String deadline;
  final String applyLink;
  final String companyLogo;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    required this.postedBy,
    this.skillsRequired = const [],
    this.salary = '',
    this.experienceRequired = 'Fresher',
    this.deadline = '',
    this.applyLink = '',
    this.companyLogo = '',
    required this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    dynamic postedByVal = json['postedBy'];
    if (postedByVal is Map<String, dynamic>) {
      postedByVal = UserModel.fromJson(postedByVal);
    }

    return JobModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? 'fulltime',
      description: json['description'] ?? '',
      postedBy: postedByVal,
      skillsRequired: (json['skillsRequired'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      salary: json['salary'] ?? '',
      experienceRequired: json['experienceRequired'] ?? 'Fresher',
      deadline: json['deadline'] ?? '',
      applyLink: json['applyLink'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'description': description,
      'postedBy': postedBy is UserModel ? (postedBy as UserModel).id : postedBy,
      'skillsRequired': skillsRequired,
      'salary': salary,
      'experienceRequired': experienceRequired,
      'deadline': deadline,
      'applyLink': applyLink,
      'companyLogo': companyLogo,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
