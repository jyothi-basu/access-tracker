import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/network/api_error_handler.dart';
import '../models/bug_models.dart';
import '../services/bug_service.dart';

final bugServiceProvider = Provider<BugService>((ref) {
  return BugService(ref.watch(apiClientProvider));
});

class BugFeedState {
  final List<BugModel> bugs;
  final String search;
  final BugFeedFilters filters;
  final bool isLoading;
  final String? errorMessage;

  const BugFeedState({
    this.bugs = const [],
    this.search = '',
    this.filters = const BugFeedFilters(),
    this.isLoading = false,
    this.errorMessage,
  });

  BugFeedState copyWith({
    List<BugModel>? bugs,
    String? search,
    BugFeedFilters? filters,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BugFeedState(
      bugs: bugs ?? this.bugs,
      search: search ?? this.search,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final bugFeedProvider = StateNotifierProvider.autoDispose<BugFeedNotifier, BugFeedState>((ref) {
  return BugFeedNotifier(ref.watch(bugServiceProvider));
});

class BugFeedNotifier extends StateNotifier<BugFeedState> {
  final BugService _service;

  BugFeedNotifier(this._service) : super(const BugFeedState()) {
    fetchBugs();
  }

  Future<void> fetchBugs() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final bugs = await _service.fetchBugs(
        search: state.search,
        applicationName: state.filters.applicationName,
        platform: state.filters.platform,
        screenReader: state.filters.screenReader,
        severity: state.filters.severity,
      );

      bugs.sort((first, second) {
        final comparison = first.createdAt.compareTo(second.createdAt);
        return state.filters.sortOrder == BugSortOrder.newest
            ? -comparison
            : comparison;
      });

      state = state.copyWith(bugs: bugs, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value);
    await fetchBugs();
  }

  Future<void> setFilters(BugFeedFilters filters) async {
    state = state.copyWith(filters: filters);
    await fetchBugs();
  }

  Future<void> setApplicationName(String applicationName) async {
    if (state.filters.applicationName == applicationName) return;
    await setFilters(
      state.filters.copyWith(applicationName: applicationName),
    );
  }
}

final bugDetailsProvider = FutureProvider.autoDispose.family<BugModel, String>((ref, bugId) {
  return ref.watch(bugServiceProvider).fetchBug(bugId);
});

/// Loads bug reports owned by the authenticated user.
final myBugsProvider = FutureProvider.autoDispose<List<BugModel>>((ref) {
  return ref.watch(bugServiceProvider).fetchMyBugs();
});

class BugMutationState {
  final bool isLoading;
  final String? errorMessage;

  const BugMutationState({this.isLoading = false, this.errorMessage});

  BugMutationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BugMutationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final bugMutationProvider =
    StateNotifierProvider.autoDispose<BugMutationNotifier, BugMutationState>((ref) {
  return BugMutationNotifier(ref.watch(bugServiceProvider));
});

/// Performs bug updates and deletions through the bug service.
class BugMutationNotifier extends StateNotifier<BugMutationState> {
  final BugService _service;

  BugMutationNotifier(this._service) : super(const BugMutationState());

  Future<bool> updateBug(String bugId, UpdateBugRequest request) async {
    return _run(() => _service.updateBug(bugId, request));
  }

  Future<bool> deleteBug(String bugId) async {
    return _run(() => _service.deleteBug(bugId));
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
