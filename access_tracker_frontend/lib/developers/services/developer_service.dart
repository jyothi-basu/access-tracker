import 'package:dio/dio.dart';
import '../models/developer_models.dart';

/// Performs developer dashboard and response API operations.
class DeveloperService {
  final Dio _dio;

  DeveloperService(this._dio);

  /// Fetches approved applications represented by the authenticated developer.
  Future<List<DeveloperApplicationSummary>> fetchApplications() async {
    final response = await _dio.get('/developers/applications');
    final items = response.data as List<dynamic>? ?? const [];
    return items
        .map((item) => DeveloperApplicationSummary.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  /// Fetches responses created by the authenticated developer.
  Future<List<DeveloperResponse>> fetchMyResponses() async {
    final response = await _dio.get('/developers/responses');
    final items = response.data as List<dynamic>? ?? const [];
    return items
        .map((item) => DeveloperResponse.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  /// Fetches every developer response for a bug.
  Future<List<DeveloperResponse>> fetchResponsesForBug(String bugId) async {
    final response = await _dio.get('/developers/bugs/$bugId/responses');
    final items = response.data as List<dynamic>? ?? const [];
    return items
        .map((item) => DeveloperResponse.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  /// Creates a response for a bug. IDs are derived by the backend.
  Future<DeveloperResponse> createResponse(
    String bugId,
    DeveloperResponseRequest request,
  ) async {
    final response = await _dio.post(
      '/developers/bugs/$bugId/responses',
      data: request.toJson(),
    );
    return DeveloperResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates one response owned by the authenticated developer.
  Future<DeveloperResponse> updateResponse(
    String responseId,
    DeveloperResponseRequest request,
  ) async {
    final response = await _dio.patch(
      '/developers/responses/$responseId',
      data: request.toJson(),
    );
    return DeveloperResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes one response owned by the authenticated developer.
  Future<void> deleteResponse(String responseId) async {
    await _dio.delete('/developers/responses/$responseId');
  }
}
