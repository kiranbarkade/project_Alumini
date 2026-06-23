import 'package:flutter/material.dart';
import '../models/referral_model.dart';
import '../repositories/referral_repository.dart';

class ReferralProvider extends ChangeNotifier {
  final ReferralRepository _referralRepository = ReferralRepository();

  List<ReferralModel> _referrals = [];
  bool _isLoading = false;
  String? _error;

  List<ReferralModel> get referrals => _referrals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReferrals({
    String? studentId,
    String? alumniId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _referrals = await _referralRepository.getReferrals(
        studentId: studentId,
        alumniId: alumniId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendReferralRequest(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRequest = await _referralRepository.createReferralRequest(data);
      _referrals.insert(0, newRequest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateReferralStatus(String id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _referralRepository.updateReferralStatus(id, status);
      
      // Update local state
      final idx = _referrals.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _referrals[idx] = updated;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
