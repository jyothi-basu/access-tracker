import 'package:dio/dio.dart';
import '../../bugs/models/bug_models.dart';
import '../models/verification_models.dart';

/// Performs verification API operations through the shared Dio client.
class VerificationService {
  final Dio _dio;

  VerificationService(this._dio);

  /// Fetches all community verifications for a bug.
  Future<List<VerificationModel>> fetchForBug(String bugId) async {
    final response = await _dio.get('/bugs/$bugId/verifications');
    final data = response.data as Map<String, dynamic>;
    final items = data['verifications'] as List<dynamic>? ?? const [];
    return items
        .map((item) => VerificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetches verifications created by the authenticated user.
  Future<List<VerificationModel>> fetchMyVerifications() async {
    final response = await _dio.get('/verifications/me');
    final data = response.data as Map<String, dynamic>;
    final items = data['verifications'] as List<dynamic>? ?? const [];
    return items
        .map((item) => VerificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the aggregated counts for a bug.
  Future<VerificationSummary> fetchSummary(String bugId) async {
    final response = await _dio.get('/bugs/$bugId/verifications/summary');
    return VerificationSummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Creates a verification for the authenticated user.
  Future<VerificationModel> create(
    String bugId,
    VerificationRequest request,
  ) async {
    final response = await _dio.post(
      '/bugs/$bugId/verifications',
      data: request.toJson(),
    );
    return VerificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates the authenticated user's verification for a bug.
  Future<VerificationModel> update(
    String bugId,
    VerificationRequest request,
  ) async {
    final response = await _dio.patch(
      '/bugs/$bugId/verifications',
      data: request.toJson(),
    );
    return VerificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes the authenticated user's verification for a bug.
  Future<void> delete(String bugId) async {
    await _dio.delete('/bugs/$bugId/verifications');
  }
}
