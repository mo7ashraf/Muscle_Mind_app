import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_controller.dart';

final trainerTraineesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await ApiService.dio.get('/trainer/trainees');
  final data = res.data as Map<String, dynamic>;
  final list = (data['data'] as List<dynamic>? ?? <dynamic>[]);
  return list;
});

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final traineesAsync = ref.watch(trainerTraineesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
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
              'Hello, ${auth.user?.name ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text('Your trainees'),
            const SizedBox(height: 8),
            Expanded(
              child: traineesAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('No trainees yet.'));
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = list[i] as Map<String, dynamic>;
                      final user = item['user'] as Map<String, dynamic>?;

                      final name = (user?['name'] ?? 'Trainee') as String;
                      final email = (user?['email'] ?? '') as String;
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
                        title: Text(name),
                        subtitle: Text(email),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(ApiService.messageFromError(e))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
