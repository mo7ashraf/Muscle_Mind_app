import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_routes.dart';
import '../../auth/providers/auth_controller.dart';

class TraineeDashboardScreen extends ConsumerWidget {
  const TraineeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

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
              'Hello, ${auth.user?.name ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _ActionCard(
                    icon: Icons.photo_camera_front,
                    title: 'My Progress',
                    subtitle: 'Photos, weight, and measurements',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.progress),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.restaurant,
                    title: 'Diet Plans',
                    subtitle: 'View your meal plan and calories',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.dietPlans),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.fitness_center,
                    title: 'Workouts',
                    subtitle: 'View and complete your workouts',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.workouts),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Coming next'),
                      subtitle: const Text('Challenges, articles, and notifications'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
