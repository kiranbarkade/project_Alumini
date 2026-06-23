import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _jobRepository = JobRepository();

  List<JobModel> _jobs = [];
  JobModel? _selectedJob;
  bool _isLoading = false;
  String? _error;

  List<JobModel> get jobs => _jobs;
  JobModel? get selectedJob => _selectedJob;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchJobs({
    String? search,
    String? type,
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobs = await _jobRepository.getJobs(
        search: search,
        type: type,
        location: location,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedJob = await _jobRepository.getJobDetails(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postJob(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newJob = await _jobRepository.createJob(data);
      _jobs.insert(0, newJob);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedJob() {
    _selectedJob = null;
    notifyListeners();
  }
}
