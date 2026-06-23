import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AlumniProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  List<UserModel> _alumni = [];
  UserModel? _selectedAlumnus;
  bool _isLoading = false;
  String? _error;

  List<UserModel> get alumni => _alumni;
  UserModel? get selectedAlumnus => _selectedAlumnus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAlumni({
    String? search,
    String? company,
    String? skills,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alumni = await _userRepository.getAlumni(
        search: search,
        company: company,
        skills: skills,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAlumnusById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedAlumnus = await _userRepository.getUserById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedAlumnus() {
    _selectedAlumnus = null;
    notifyListeners();
  }
}
