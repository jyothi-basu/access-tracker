import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/providers.dart';
import '../../bugs/models/bug_models.dart';
import '../../bugs/providers/bug_provider.dart';
import '../models/verification_models.dart';
import '../services/verification_service.dart';

final verificationServiceProvider = Provider<VerificationService>((ref) {
  return VerificationService(ref.watch(apiClientProvider));
});

/// Loads the summary used by the bug details screen.
final verificationSummaryProvider =
    FutureProvider.autoDispose.family<VerificationSummary, String>((ref, bugId) {
  return ref.watch(verificationServiceProvider).fetchSummary(bugId);
});

/// Loads all verifications for a bug.
final verificationListProvider =
    FutureProvider.autoDispose.family<List<VerificationModel>, String>((ref, bugId) {
  return ref.watch(verificationServiceProvider).fetchForBug(bugId);
});

/// Loads the user's verifications and enriches them with their bug metadata.
final myVerificationsProvider =
    FutureProvider.autoDispose<List<MyVerificationItem>>((ref) async {
  final verifications = await ref
      .watch(verificationServiceProvider)
      .fetchMyVerifications();
  final bugService = ref.watch(bugServiceProvider);

  return Future.wait(
    verifications.map((verification) async {
      final bug = await bugService.fetchBug(verification.bugId);
      return MyVerificationItem(
        verification: verification,
        applicationName: bug.applicationName,
        bugTitle: bug.title,
      );
    }),
  );
});

/// State for create, edit, and delete actions.
class VerificationActionState {
  final bool isLoading;
  final String? errorMessage;

  const VerificationActionState({
    this.isLoading = false,
    this.errorMessage,
  });

  VerificationActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VerificationActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final verificationActionProvider = StateNotifierProvider.autoDispose<
    VerificationActionNotifier, VerificationActionState>((ref) {
  return VerificationActionNotifier(ref.watch(verificationServiceProvider));
});

/// Executes verification mutations and converts API failures to user messages.
class VerificationActionNotifier
    extends StateNotifier<VerificationActionState> {
  final VerificationService _service;

  VerificationActionNotifier(this._service)
      : super(const VerificationActionState());

  Future<bool> create(String bugId, VerificationRequest request) async {
    return _run(() => _service.create(bugId, request));
  }

  Future<bool> update(String bugId, VerificationRequest request) async {
    return _run(() => _service.update(bugId, request));
  }

  Future<bool> delete(String bugId) async {
    return _run(() => _service.delete(bugId));
  }

  Future<bool> _run(Future<dynamic> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _verificationErrorMessage(error),
      );
      return false;
    }
  }

  String _verificationErrorMessage(dynamic error) {
    if (error is DioException && error.response?.statusCode == 409) {
      final detail = error.response?.data is Map
          ? error.response?.data['detail']
          : null;
      if (detail is String && detail.trim().isNotEmpty) return detail;
    }

    return ApiErrorHandler.handle(error);
  }
}
