class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String college;
  final String branch;
  final int graduationYear;
  final String company;
  final String designation;
  final List<String> skills;
  final String profileImage;
  final String linkedinUrl;
  final String about;
  final String resumeUrl;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.college = 'Zeal College of Engineering and Research',
    this.branch = '',
    this.graduationYear = 0,
    this.company = '',
    this.designation = '',
    this.skills = const [],
    this.profileImage = '',
    this.linkedinUrl = '',
    this.about = '',
    this.resumeUrl = '',
    this.isVerified = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      college: json['college'] ?? 'Zeal College of Engineering and Research',
      branch: json['branch'] ?? '',
      graduationYear: json['graduationYear'] is int
          ? json['graduationYear']
          : int.tryParse(json['graduationYear']?.toString() ?? '0') ?? 0,
      company: json['company'] ?? '',
      designation: json['designation'] ?? '',
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      profileImage: json['profileImage'] ?? '',
      linkedinUrl: json['linkedinUrl'] ?? '',
      about: json['about'] ?? '',
      resumeUrl: json['resumeUrl'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'college': college,
      'branch': branch,
      'graduationYear': graduationYear,
      'company': company,
      'designation': designation,
      'skills': skills,
      'profileImage': profileImage,
      'linkedinUrl': linkedinUrl,
      'about': about,
      'resumeUrl': resumeUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? college,
    String? branch,
    int? graduationYear,
    String? company,
    String? designation,
    List<String>? skills,
    String? profileImage,
    String? linkedinUrl,
    String? about,
    String? resumeUrl,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      graduationYear: graduationYear ?? this.graduationYear,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      skills: skills ?? this.skills,
      profileImage: profileImage ?? this.profileImage,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      about: about ?? this.about,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
