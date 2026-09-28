import 'package:dio/dio.dart';
import '../../core/network/api_error_handler.dart';
import '../models/application_model.dart';

/// Reads existing applications from the AccessTracker backend.
class ApplicationService {
  final Dio _dio;

  ApplicationService(this._dio);

  /// Searches applications by display name.
  Future<List<ApplicationModel>> searchApplications(String query) async {
    try {
      final response = await _dio.get(
        '/applications',
        queryParameters: {'search': query},
      );

      final applications = response.data as List<dynamic>;
      return applications
          .map((application) => ApplicationModel.fromJson(application as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw ApplicationServiceException(ApiErrorHandler.handle(error));
    }
  }
}

/// User-facing error raised when application search cannot be completed.
class ApplicationServiceException implements Exception {
  final String message;

  const ApplicationServiceException(this.message);

  @override
  String toString() => message;
}
