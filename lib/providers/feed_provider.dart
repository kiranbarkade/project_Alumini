import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../repositories/post_repository.dart';

class FeedProvider extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();

  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postRepository.getPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(
    String userId,
    String content, {
    String image = '',
    List<String> tags = const [],
    String company = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPost = await _postRepository.createPost({
        'userId': userId,
        'content': content,
        'image': image,
        'tags': tags,
        'company': company,
      });
      _posts.insert(0, newPost);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final updatedPost = await _postRepository.likePost(postId, userId);
      
      // Update local state list
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addComment(String postId, String userId, String content) async {
    try {
      final updatedPost = await _postRepository.commentPost(postId, userId, content);
      
      // Update local state list
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
