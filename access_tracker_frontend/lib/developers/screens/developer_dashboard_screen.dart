import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';
import '../../core/network/api_error_handler.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../providers/developer_provider.dart';

/// Shows approved applications and response history for a developer.
class DeveloperDashboardScreen extends ConsumerWidget {
  final bool isActive;

  const DeveloperDashboardScreen({
    super.key,
    this.isActive = true,
  });

  Future<void> _showClaimInformation(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Claim Developer Status'),
        content: const Text(
          'The developer application workflow is planned for a future version. '
          'For now, approved developer relationships are managed by the AccessTracker team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isDeveloperAccessDenied(Object error) {
    return error is DioException && error.response?.statusCode == 403;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) return const SizedBox.shrink();

    final user = ref.watch(authProvider).currentUser;
    final applicationsState = ref.watch(developerApplicationsProvider);

    if (applicationsState.isLoading) {
      return const LoadingIndicator();
    }

    return applicationsState.when(
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) => _isDeveloperAccessDenied(error)
          ? _NoDeveloperStatus(
              onClaim: () => _showClaimInformation(context),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ErrorBanner(error: ApiErrorHandler.handle(error)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(developerApplicationsProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
      data: (applications) {
        if (applications.isEmpty) {
          return _NoDeveloperStatus(
            onClaim: () => _showClaimInformation(context),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Welcome, ${user?.name ?? 'Developer'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Manage accessibility responses for your applications.'),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Approved Applications'),
                    const SizedBox(height: 8),
                    Text(
                      '${applications.length}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...applications.map(
              (application) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          application.applicationName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('${application.bugCount} bugs reported'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final uri = Uri(
                              path: '/bugs',
                              queryParameters: {
                                'application_name': application.applicationName,
                              },
                            );
                            context.push(uri.toString());
                          },
                          child: const Text('View'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/developers/responses'),
                child: const Text('View All My Responses'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showClaimInformation(context),
                child: const Text('Claim Developer Status'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NoDeveloperStatus extends StatelessWidget {
  final VoidCallback onClaim;

  const _NoDeveloperStatus({required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Developer Access',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Hi! You don't currently have developer status for any application on AccessTracker.",
                ),
                const SizedBox(height: 12),
                const Text(
                  'If you are a developer, you can apply for developer status by selecting your application and providing the necessary details for verification.',
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onClaim,
                  child: const Text('Claim Developer Status'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
