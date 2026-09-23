import 'package:dio/dio.dart';
import '../models/auth_models.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<MessageResponse> register(RegisterRequest request) async {
    final response = await _dio.post('/auth/register', data: request.toJson());
    return MessageResponse.fromJson(response.data);
  }

  Future<MessageResponse> resendRegistrationOtp(OtpRequest request) async {
    final response = await _dio.post('/auth/register/resend-otp', data: request.toJson());
    return MessageResponse.fromJson(response.data);
  }

  Future<MessageResponse> verifyRegistrationOtp(VerifyRegistrationRequest request) async {
    final response = await _dio.post('/auth/register/verify', data: request.toJson());
    return MessageResponse.fromJson(response.data);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post('/auth/login', data: request.toJson());
    return AuthResponse.fromJson(response.data);
  }

  Future<MessageResponse> logout(LogoutRequest request) async {
    final response = await _dio.post('/auth/logout', data: request.toJson());
    return MessageResponse.fromJson(response.data);
  }

  Future<TokenPairResponse> refresh(RefreshRequest request) async {
    final response = await _dio.post('/auth/refresh', data: request.toJson());
    return TokenPairResponse.fromJson(response.data);
  }

  Future<UserResponse> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return UserResponse.fromJson(response.data);
  }

  Future<MessageResponse> requestPasswordResetOtp(OtpRequest request) async {
    final response = await _dio.post('/auth/forgot-password/request-otp', data: request.toJson());
    return MessageResponse.fromJson(response.data);
  }

  Future<ResetTokenResponse> verifyPasswordResetOtp(VerifyRegistrationRequest request) async {
    final response = await _dio.post('/auth/forgot-password/verify-otp', data: request.toJson());
    return ResetTokenResponse.fromJson(response.data);
  }

  Future<MessageResponse> resetPassword(ResetPasswordRequest request) async {
    final response = await _dio.post('/auth/forgot-password/reset', data: request.toJson());
    return MessageResponse.fromJson(response.data);
  }
}
