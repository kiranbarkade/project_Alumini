import 'user_model.dart';

class CommentModel {
  final String id;
  final dynamic userId; // Can be a String ID or a UserModel instance
  final String userName;
  final String userImage;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    dynamic userVal = json['userId'];
    if (userVal is Map<String, dynamic>) {
      userVal = UserModel.fromJson(userVal);
    }

    return CommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userVal,
      userName: json['userName'] ?? '',
      userImage: json['userImage'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId is UserModel ? (userId as UserModel).id : userId,
      'userName': userName,
      'userImage': userImage,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PostModel {
  final String id;
  final dynamic userId; // Can be a String ID or a UserModel instance
  final String content;
  final String image;
  final List<String> tags;
  final String company;
  final List<String> likes; // User IDs
  final List<CommentModel> comments;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.image = '',
    this.tags = const [],
    this.company = '',
    this.likes = const [],
    this.comments = const [],
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    dynamic userVal = json['userId'];
    if (userVal is Map<String, dynamic>) {
      userVal = UserModel.fromJson(userVal);
    }

    return PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userVal,
      content: json['content'] ?? '',
      image: json['image'] ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      company: json['company'] ?? '',
      likes:
          (json['likes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId is UserModel ? (userId as UserModel).id : userId,
      'content': content,
      'image': image,
      'tags': tags,
      'company': company,
      'likes': likes,
      'comments': comments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
