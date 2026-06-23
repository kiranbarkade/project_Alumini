import '../models/referral_model.dart';
import '../services/api_client.dart';

class ReferralRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ReferralModel> createReferralRequest(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/referrals', data);
    return ReferralModel.fromJson(response['data']);
  }

  Future<List<ReferralModel>> getReferrals({
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

    final response = await _apiClient.get('/referrals$query');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((json) => ReferralModel.fromJson(json)).toList();
  }

  Future<ReferralModel> updateReferralStatus(String id, String status) async {
    final response = await _apiClient.put('/referrals/$id', {'status': status});
    return ReferralModel.fromJson(response['data']);
  }
}
