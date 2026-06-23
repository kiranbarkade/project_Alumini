import '../models/job_model.dart';
import '../services/api_client.dart';

class JobRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<JobModel>> getJobs({
    String? search,
    String? type,
    String? location,
  }) async {
    String query = '?';
    if (search != null && search.isNotEmpty) {
      query += '&search=${Uri.encodeComponent(search)}';
    }
    if (type != null && type.isNotEmpty && type != 'All') {
      query += '&type=${Uri.encodeComponent(type.toLowerCase())}';
    }
    if (location != null && location.isNotEmpty) {
      query += '&location=${Uri.encodeComponent(location)}';
    }

    final response = await _apiClient.get('/jobs$query');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => JobModel.fromJson(json)).toList();
  }

  Future<JobModel> getJobDetails(String id) async {
    final response = await _apiClient.get('/jobs/$id');
    return JobModel.fromJson(response['data']);
  }

  Future<JobModel> createJob(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/jobs', data);
    return JobModel.fromJson(response['data']);
  }
}
