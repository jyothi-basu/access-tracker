import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/network/api_error_handler.dart';
import '../models/auth_models.dart';
import '../service/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

class AuthState {
  final UserResponse? currentUser;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitializing;

  AuthState({
    this.currentUser,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.isInitializing = true,
  });

  AuthState copyWith({
    UserResponse? currentUser,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    bool? isInitializing,
    bool clearCurrentUser = false,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      currentUser: clearCurrentUser ? null : (currentUser ?? this.currentUser),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(AuthState()) {
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final token = await _ref.read(secureStorageProvider).readAccessToken();
    if (token == null) {
      state = state.copyWith(isInitializing: false, isAuthenticated: false);
      return;
    }

    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(currentUser: user, isAuthenticated: true, isInitializing: false);
    } catch (e) {
      await _ref.read(secureStorageProvider).clearTokens();
      state = state.copyWith(isInitializing: false, isAuthenticated: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final response = await _authService.login(LoginRequest(email: email, password: password));
      await _ref.read(secureStorageProvider).saveAccessToken(response.tokens.access_token);
      await _ref.read(secureStorageProvider).saveRefreshToken(response.tokens.refresh_token);
      state = state.copyWith(currentUser: response.user, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, errorMessage: ApiErrorHandler.handle(e));
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _authService.register(RegisterRequest(name: name, email: email, password: password));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: ApiErrorHandler.handle(e));
      return false;
    }
  }

  Future<bool> verifyRegistrationOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _authService.verifyRegistrationOtp(VerifyRegistrationRequest(email: email, otp: otp));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: ApiErrorHandler.handle(e));
      return false;
    }
  }

  Future<void> resendRegistrationOtp(String email) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _authService.resendRegistrationOtp(OtpRequest(email: email));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: ApiErrorHandler.handle(e));
    }
  }

  Future<void> requestPasswordResetOtp(String email) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _authService.requestPasswordResetOtp(OtpRequest(email: email));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: ApiErrorHandler.handle(e));
    }
  }

  Future<String?> verifyPasswordResetOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final response = await _authService.verifyPasswordResetOtp(VerifyRegistrationRequest(email: email, otp: otp));
      state = state.copyWith(isLoading: false);
      return response.reset_token;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: ApiErrorHandler.handle(e));
      return null;
    }
  }

  Future<void> resetPassword(String resetToken, String password) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _authService.resetPassword(ResetPasswordRequest(reset_token: resetToken, new_password: password));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: ApiErrorHandler.handle(e));
    }
  }

  Future<void> logout() async {
    final refresh = await _ref.read(secureStorageProvider).readRefreshToken();
    if (refresh != null) {
      try {
        await _authService.logout(LogoutRequest(refresh_token: refresh));
      } catch (_) {}
    }
    await _ref.read(secureStorageProvider).clearTokens();
    state = AuthState(isInitializing: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});
