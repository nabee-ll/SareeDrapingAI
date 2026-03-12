enum JobStatus { queued, processing, done, failed, cancelled }

class TryOnJob {
  final String id;
  final String userId;
  final String assetId;
  final JobStatus status;
  final String? resultImageUrl;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TryOnJob({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.status,
    this.resultImageUrl,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  bool get isTerminal =>
      status == JobStatus.done ||
      status == JobStatus.failed ||
      status == JobStatus.cancelled;

  factory TryOnJob.fromJson(Map<String, dynamic> json) {
    return TryOnJob(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      assetId: json['asset_id'] as String? ?? '',
      status: _parseStatus(json['status'] as String? ?? 'queued'),
      resultImageUrl: json['result_image_url'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'asset_id': assetId,
        'status': status.name,
        'result_image_url': resultImageUrl,
        'error_message': errorMessage,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  static JobStatus _parseStatus(String s) {
    return JobStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => JobStatus.queued,
    );
  }
}
