import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../auth/models/auth_models.dart';
import '../storage/secure_storage_service.dart';

class DioInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final Dio _dio;
  Completer<String?>? _refreshCompleter;

  DioInterceptor(this._storageService, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('[Dio] OUTGOING ${options.method} ${options.uri}');
    debugPrint('[Dio] REQUEST BODY: ${options.data}');
    final token = await _storageService.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('[Dio] NETWORK ERROR ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('[Dio] ERROR TYPE: ${err.type}; STATUS: ${err.response?.statusCode}');
    debugPrint('[Dio] ERROR BODY: ${err.response?.data}');
    if (err.response?.statusCode == 401 && _shouldRefresh(err.requestOptions)) {
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (e) {
        // Logout handled in _refreshToken
      }
    }
    handler.next(err);
  }

  bool _shouldRefresh(RequestOptions options) {
    final excludePaths = [
      '/auth/login',
      '/auth/register',
      '/auth/register/verify',
      '/auth/register/resend-otp',
      '/auth/refresh',
      '/auth/forgot-password/request-otp',
      '/auth/forgot-password/verify-otp',
      '/auth/forgot-password/reset',
    ];
    return !excludePaths.any((path) => options.path.contains(path));
  }

  Future<String?> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();
    
    try {
      final refreshToken = await _storageService.readRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token');
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: RefreshRequest(refresh_token: refreshToken).toJson(),
      );
      final tokenPair = TokenPairResponse.fromJson(response.data);
      
      await _storageService.saveAccessToken(tokenPair.access_token);
      await _storageService.saveRefreshToken(tokenPair.refresh_token);
      
      _refreshCompleter!.complete(tokenPair.access_token);
      return tokenPair.access_token;
    } catch (e) {
      await _storageService.clearTokens();
      _refreshCompleter!.complete(null);
      throw e;
    } finally {
      _refreshCompleter = null;
    }
  }
}
