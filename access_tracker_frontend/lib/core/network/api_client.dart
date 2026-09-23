import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';
import '../network/dio_interceptor.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  static Dio create(SecureStorageService storageService) {
    final configuredBaseUrl = dotenv.env[ApiConstants.backendUrlKey]?.trim();
    
    if (configuredBaseUrl == null || configuredBaseUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL is not configured in .env');
    }

    final baseUrl = configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final fullBaseUrl = '$baseUrl${ApiConstants.baseApiPath}';
    debugPrint('[ApiClient] Dio baseUrl: $fullBaseUrl');

    final dio = Dio(
      BaseOptions(
        baseUrl: fullBaseUrl,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (dotenv.env['APP_ENV'] == 'development') {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          logPrint: (message) => debugPrint('[Dio] $message'),
        ),
      );
    }

    dio.interceptors.add(DioInterceptor(storageService, dio));

    return dio;
  }
}
