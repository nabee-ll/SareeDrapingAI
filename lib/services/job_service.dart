import '../core/config/api_config.dart';
import '../models/job_model.dart';
import 'api_client.dart';

class JobService {
  const JobService();
  static final _api = ApiClient.instance;

  /// Create a new try-on job. Returns the created [TryOnJob].
  Future<JobResult> createJob({
    required String assetId,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    final res = await _api.multipartPost(
      ApiConfig.jobs,
      {'asset_id': assetId},
      [
        MultipartFile(
          field: 'photo',
          bytes: photoBytes,
          filename: photoFilename,
        ),
      ],
    );
    if (res.ok && res.data is Map) {
      return JobResult(job: TryOnJob.fromJson(res.data as Map<String, dynamic>));
    }
    return JobResult(error: res.errorMessage ?? 'Failed to create job');
  }

  /// Poll job status.
  Future<JobResult> getJob(String jobId) async {
    final res = await _api.get(ApiConfig.jobById(jobId));
    if (res.ok && res.data is Map) {
      return JobResult(job: TryOnJob.fromJson(res.data as Map<String, dynamic>));
    }
    return JobResult(error: res.errorMessage ?? 'Failed to fetch job');
  }

  /// Cancel a queued job.
  Future<bool> cancelJob(String jobId) async {
    final res = await _api.delete(ApiConfig.jobById(jobId));
    return res.ok;
  }

  /// Fetch all jobs for the current user.
  Future<List<TryOnJob>> getJobs() async {
    final res = await _api.get(ApiConfig.jobs);
    if (res.ok && res.data is List) {
      return (res.data as List)
          .map((e) => TryOnJob.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

class JobResult {
  final TryOnJob? job;
  final String? error;
  const JobResult({this.job, this.error});
  bool get ok => job != null && error == null;
}
