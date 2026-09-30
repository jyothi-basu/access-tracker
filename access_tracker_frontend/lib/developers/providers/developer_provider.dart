import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/providers.dart';
import '../models/developer_models.dart';
import '../services/developer_service.dart';

final developerServiceProvider = Provider<DeveloperService>((ref) {
  return DeveloperService(ref.watch(apiClientProvider));
});

/// Loads the authenticated user's approved developer applications.
final developerApplicationsProvider =
    FutureProvider.autoDispose<List<DeveloperApplicationSummary>>((ref) async {
  return ref.watch(developerServiceProvider).fetchApplications();
});

/// Loads responses created by the authenticated developer.
final developerMyResponsesProvider =
    FutureProvider.autoDispose<List<DeveloperResponse>>((ref) {
  return ref.watch(developerServiceProvider).fetchMyResponses();
});

/// Loads all developer responses associated with one bug.
final developerResponsesForBugProvider = FutureProvider.autoDispose
    .family<List<DeveloperResponse>, String>((ref, bugId) {
  return ref.watch(developerServiceProvider).fetchResponsesForBug(bugId);
});

class DeveloperResponseActionState {
  final bool isLoading;
  final String? errorMessage;

  const DeveloperResponseActionState({
    this.isLoading = false,
    this.errorMessage,
  });

  DeveloperResponseActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeveloperResponseActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final developerResponseActionProvider = StateNotifierProvider.autoDispose<
    DeveloperResponseActionNotifier, DeveloperResponseActionState>((ref) {
  return DeveloperResponseActionNotifier(ref.watch(developerServiceProvider));
});

/// Executes developer response mutations and exposes user-friendly failures.
class DeveloperResponseActionNotifier
    extends StateNotifier<DeveloperResponseActionState> {
  final DeveloperService _service;

  DeveloperResponseActionNotifier(this._service)
      : super(const DeveloperResponseActionState());

  Future<bool> create(String bugId, DeveloperResponseRequest request) {
    return _run(() => _service.createResponse(bugId, request));
  }

  Future<bool> update(
    String responseId,
    DeveloperResponseRequest request,
  ) {
    return _run(() => _service.updateResponse(responseId, request));
  }

  Future<bool> delete(String responseId) {
    return _run(() => _service.deleteResponse(responseId));
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
        errorMessage: ApiErrorHandler.handle(error),
      );
      return false;
    }
  }
}
