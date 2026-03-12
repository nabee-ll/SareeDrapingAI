import 'dart:async';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

enum JobProviderState { idle, submitting, polling, done, failed, error }

class JobProvider extends ChangeNotifier {
  final JobService _jobService = const JobService();

  JobProviderState _state = JobProviderState.idle;
  TryOnJob? _currentJob;
  List<TryOnJob> _jobHistory = [];
  String? _errorMessage;
  Timer? _pollTimer;

  JobProviderState get state => _state;
  TryOnJob? get currentJob => _currentJob;
  List<TryOnJob> get jobHistory => List.unmodifiable(_jobHistory);
  String? get errorMessage => _errorMessage;
  bool get isActive =>
      _state == JobProviderState.submitting ||
      _state == JobProviderState.polling;

  // ── Submit Job ────────────────────────────────────────────────────────────

  Future<void> submitJob({
    required String assetId,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    _cancelPolling();
    _state = JobProviderState.submitting;
    _currentJob = null;
    _errorMessage = null;
    notifyListeners();

    final result = await _jobService.createJob(
      assetId: assetId,
      photoBytes: photoBytes,
      photoFilename: photoFilename,
    );

    if (result.ok) {
      _currentJob = result.job;
      _state = JobProviderState.polling;
      notifyListeners();
      _startPolling(result.job!.id);
    } else {
      _state = JobProviderState.error;
      _errorMessage = result.error;
      notifyListeners();
    }
  }

  // ── Poll Job Status ───────────────────────────────────────────────────────

  void _startPolling(String jobId) {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final result = await _jobService.getJob(jobId);
      if (result.ok && result.job != null) {
        _currentJob = result.job;
        if (result.job!.status == JobStatus.done) {
          _cancelPolling();
          _state = JobProviderState.done;
          notifyListeners();
        } else if (result.job!.status == JobStatus.failed ||
            result.job!.status == JobStatus.cancelled) {
          _cancelPolling();
          _state = JobProviderState.failed;
          _errorMessage = result.job!.errorMessage ?? 'Job failed.';
          notifyListeners();
        } else {
          notifyListeners();
        }
      }
    });
  }

  void _cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Cancel Job ────────────────────────────────────────────────────────────

  Future<void> cancelCurrentJob() async {
    _cancelPolling();
    if (_currentJob != null) {
      await _jobService.cancelJob(_currentJob!.id);
    }
    _state = JobProviderState.idle;
    _currentJob = null;
    notifyListeners();
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    _jobHistory = await _jobService.getJobs();
    notifyListeners();
  }

  void reset() {
    _cancelPolling();
    _state = JobProviderState.idle;
    _currentJob = null;
    _jobHistory = [];
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelPolling();
    super.dispose();
  }
}
