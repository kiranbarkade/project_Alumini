import 'package:flutter/material.dart';
import '../models/mentorship_model.dart';
import '../repositories/mentorship_repository.dart';

class MentorshipProvider extends ChangeNotifier {
  final MentorshipRepository _mentorshipRepository = MentorshipRepository();

  List<MentorshipModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<MentorshipModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSessions({
    String? studentId,
    String? alumniId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _mentorshipRepository.getMentorshipSessions(
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

  Future<bool> requestSession(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSession = await _mentorshipRepository.createMentorshipRequest(data);
      _sessions.insert(0, newSession);
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

  Future<void> updateSessionStatus(String id, String status, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _mentorshipRepository.updateMentorshipStatus(
        id,
        status,
        notes: notes,
      );

      // Update local state list
      final idx = _sessions.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _sessions[idx] = updated;
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
