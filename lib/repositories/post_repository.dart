import '../models/post_model.dart';
import '../services/api_client.dart';

class PostRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<PostModel>> getPosts() async {
    final response = await _apiClient.get('/posts');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => PostModel.fromJson(json)).toList();
  }

  Future<PostModel> createPost(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/posts', data);
    return PostModel.fromJson(response['data']);
  }

  Future<PostModel> likePost(String postId, String userId) async {
    final response = await _apiClient.put('/posts/$postId/like', {'userId': userId});
    return PostModel.fromJson(response['data']);
  }

  Future<PostModel> commentPost(String postId, String userId, String content) async {
    final response = await _apiClient.post(
      '/posts/$postId/comments',
      {
        'userId': userId,
        'content': content,
      },
    );
    return PostModel.fromJson(response['data']);
  }
}
