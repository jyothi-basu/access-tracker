import 'package:dio/dio.dart';
import '../models/bug_models.dart';

/// Reads and creates bug reports through the FastAPI backend.
class BugService {
  final Dio _dio;

  BugService(this._dio);

  /// Fetches bug reports using the backend's supported query filters.
  Future<List<BugModel>> fetchBugs({
    String? search,
    String? applicationId,
    String? applicationName,
    String? platform,
    String? screenReader,
    String? severity,
  }) async {
    final queryParameters = <String, dynamic>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (applicationId != null && applicationId.trim().isNotEmpty)
        'application_id': applicationId.trim(),
      if (applicationName != null && applicationName.trim().isNotEmpty)
        'application_name': applicationName.trim(),
      if (platform != null) 'platform': platform,
      if (screenReader != null) 'screen_reader': screenReader,
      if (severity != null) 'severity': severity,
    };

    final response = await _dio.get(
      '/bugs',
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final bugs = data['bugs'] as List<dynamic>? ?? const [];
    return bugs
        .map((bug) => BugModel.fromJson(bug as Map<String, dynamic>))
        .toList();
  }

  /// Fetches one bug report by ID.
  Future<BugModel> fetchBug(String bugId) async {
    final response = await _dio.get('/bugs/$bugId');
    return BugModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Creates a bug report and returns the saved report.
  Future<BugModel> createBug(CreateBugRequest request) async {
    final response = await _dio.post('/bugs', data: request.toJson());
    return BugModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches bug reports owned by the authenticated user.
  Future<List<BugModel>> fetchMyBugs() async {
    final response = await _dio.get('/bugs/me');
    final data = response.data as Map<String, dynamic>;
    final bugs = data['bugs'] as List<dynamic>? ?? const [];
    return bugs
        .map((bug) => BugModel.fromJson(bug as Map<String, dynamic>))
        .toList();
  }

  /// Updates the authenticated user's bug report.
  Future<BugModel> updateBug(String bugId, UpdateBugRequest request) async {
    final response = await _dio.patch('/bugs/$bugId', data: request.toJson());
    return BugModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes the authenticated user's bug report.
  Future<void> deleteBug(String bugId) async {
    await _dio.delete('/bugs/$bugId');
  }

  /// Fetches aggregated verification counts for one bug.
  Future<VerificationSummary> fetchVerificationSummary(String bugId) async {
    final response = await _dio.get('/bugs/$bugId/verifications/summary');
    return VerificationSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
