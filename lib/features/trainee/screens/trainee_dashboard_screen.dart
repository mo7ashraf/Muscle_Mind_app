import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_controller.dart';

final traineeProgressProvider = FutureProvider.autoDispose<int>((ref) async {
  final res = await ApiService.dio.get('/trainee/progress');
  final data = res.data as Map<String, dynamic>;
  final list = (data['data'] as List<dynamic>? ?? <dynamic>[]);
  return list.length;
});

class TraineeDashboardScreen extends ConsumerWidget {
  const TraineeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final progressAsync = ref.watch(traineeProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainee Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${auth.user?.name ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart),
                    const SizedBox(width: 12),
                    Expanded(
                      child: progressAsync.when(
                        data: (count) => Text('Progress entries: $count'),
                        loading: () => const Text('Loading progress...'),
                        error: (e, _) => Text(ApiService.messageFromError(e)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Next: build Progress, Diet, Workouts screens (Phase 2).',
            ),
          ],
        ),
      ),
    );
  }
}
