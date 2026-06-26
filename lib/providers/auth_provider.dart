import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  List<UserModel> _availableUsers = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get availableUsers => _availableUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set default role or retrieve simulated user
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userRepository.getAlumni(search: '');
      _availableUsers = response;
    } catch (e) {
      _error = e.toString();
      // Set up in-memory mock users if backend is offline
      _availableUsers = [
        UserModel(
          id: 'user_student_1',
          name: 'Yuraj Patil',
          email: 'yuraj.patil.comp23@zeal.edu.in',
          role: 'student',
          college: 'Zeal College of Engineering and Research',
          branch: 'Computer Engineering',
          graduationYear: 2027,
          skills: ['Dart', 'Flutter', 'Firebase', 'Java'],
          profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=yuraj',
          linkedinUrl: 'https://linkedin.com/in/yuraj-patil',
          about: 'Pre-final year Computer Engineering student at Zeal. Learning Flutter app development.',
          resumeUrl: 'https://zeal-portal.web.app/resumes/yuraj_patil.pdf',
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: 'user_alumni_1',
          name: 'Anjali Sharma',
          email: 'anjali.sharma@google.com',
          role: 'alumni',
          college: 'Zeal College of Engineering and Research',
          branch: 'Computer Engineering',
          graduationYear: 2022,
          company: 'Google',
          designation: 'Software Engineer III',
          skills: ['Flutter', 'Dart', 'Go', 'Kubernetes'],
          profileImage: 'https://api.dicebear.com/7.x/adventurer/svg?seed=anjali',
          linkedinUrl: 'https://linkedin.com/in/anjali-sharma-zeal',
          about: 'Software Engineer at Google. Graduated from Zeal in 2022.',
          isVerified: true,
          createdAt: DateTime.now(),
        ),
      ];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void switchUser(String userId) {
    try {
      final user = _availableUsers.firstWhere((u) => u.id == userId);
      _currentUser = user;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to switch user: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userRepository.loginUser(email, password);
      _currentUser = user;
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

  Future<bool> signUp(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userRepository.createUser(data);
      _currentUser = user;
      if (!_availableUsers.any((u) => u.id == user.id)) {
        _availableUsers.add(user);
      }
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

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_currentUser == null) return;
    try {
      final updated = await _userRepository.getUserById(_currentUser!.id);
      _currentUser = updated;
      
      // Update in availableUsers list
      final idx = _availableUsers.indexWhere((u) => u.id == updated.id);
      if (idx != -1) {
        _availableUsers[idx] = updated;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _userRepository.updateProfile(_currentUser!.id, data);
      _currentUser = updated;
      
      // Update in availableUsers list
      final idx = _availableUsers.indexWhere((u) => u.id == updated.id);
      if (idx != -1) {
        _availableUsers[idx] = updated;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadProfileImage(String base64Image) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _userRepository.uploadProfileImage(_currentUser!.id, base64Image);
      _currentUser = updated;
      
      // Update in availableUsers list
      final idx = _availableUsers.indexWhere((u) => u.id == updated.id);
      if (idx != -1) {
        _availableUsers[idx] = updated;
      }
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
}
