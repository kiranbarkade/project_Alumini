import '../models/mentorship_model.dart';
import '../services/api_client.dart';

class MentorshipRepository {
  final ApiClient _apiClient = ApiClient();

  Future<MentorshipModel> createMentorshipRequest(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/mentorships', data);
    return MentorshipModel.fromJson(response['data']);
  }

  Future<List<MentorshipModel>> getMentorshipSessions({
    String? studentId,
    String? alumniId,
  }) async {
    String query = '?';
    if (studentId != null && studentId.isNotEmpty) {
      query += '&studentId=$studentId';
    }
    if (alumniId != null && alumniId.isNotEmpty) {
      query += '&alumniId=$alumniId';
    }

    final response = await _apiClient.get('/mentorships$query');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => MentorshipModel.fromJson(json)).toList();
  }

  Future<MentorshipModel> updateMentorshipStatus(
    String id,
    String status, {
    String? notes,
  }) async {
    final body = {'status': status};
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.put('/mentorships/$id', body);
    return MentorshipModel.fromJson(response['data']);
  }
}
