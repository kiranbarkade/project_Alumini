import '../models/user_model.dart';
import '../services/api_client.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<UserModel>> getAlumni({
    String? search,
    String? company,
    String? skills,
  }) async {
    String query = '?role=alumni';
    if (search != null && search.isNotEmpty) {
      query += '&search=${Uri.encodeComponent(search)}';
    }
    if (company != null && company.isNotEmpty) {
      query += '&company=${Uri.encodeComponent(company)}';
    }
    if (skills != null && skills.isNotEmpty) {
      query += '&skills=${Uri.encodeComponent(skills)}';
    }

    final response = await _apiClient.get('/users$query');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<List<UserModel>> getStudents({
    String? search,
    String? branch,
    String? skills,
  }) async {
    String query = '?role=student';
    if (search != null && search.isNotEmpty) {
      query += '&search=${Uri.encodeComponent(search)}';
    }
    if (branch != null && branch.isNotEmpty) {
      query += '&branch=${Uri.encodeComponent(branch)}';
    }
    if (skills != null && skills.isNotEmpty) {
      query += '&skills=${Uri.encodeComponent(skills)}';
    }

    final response = await _apiClient.get('/users$query');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel> getUserById(String id) async {
    final response = await _apiClient.get('/users/$id');
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> loginUser(String email, String password) async {
    final response = await _apiClient.post('/users/login', {'email': email, 'password': password});
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/users', data);
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> updateProfile(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/users/$id', data);
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> uploadProfileImage(String id, String base64Image) async {
    final response = await _apiClient.put('/users/$id/profile-image', {
      'image': base64Image,
    });
    return UserModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final response = await _apiClient.get('/users/stats/admin');
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> getAlumniStats(String id) async {
    final response = await _apiClient.get('/users/stats/alumni/$id');
    return response['data'] ?? {};
  }
}
