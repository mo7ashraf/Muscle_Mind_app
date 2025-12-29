import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/diet_plan_model.dart';
import '../providers/diet_providers.dart';

class DietPlansScreen extends ConsumerWidget {
  const DietPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isTrainer = auth.user?.role == 'trainer';
    final plansAsync = ref.watch(dietPlansProvider);
    final filter = ref.watch(dietStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plans'),
        actions: [
          PopupMenuButton<String?>(
            initialValue: filter,
            onSelected: (v) {
              ref.read(dietStatusFilterProvider.notifier).state = v;
              ref.invalidate(dietPlansProvider);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('All')),
              PopupMenuItem(value: 'active', child: Text('Active')),
              PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
            icon: const Icon(Icons.filter_alt_outlined),
          )
        ],
      ),
      floatingActionButton: isTrainer
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createDietPlan),
              icon: const Icon(Icons.add),
              label: const Text('New Plan'),
            )
          : null,
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(child: Text('No diet plans yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final p = plans[i];
              return _DietPlanCard(
                plan: p,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.dietPlanDetails,
                  arguments: p.id,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ApiService.messageFromError(e))),
      ),
    );
  }
}

class _DietPlanCard extends StatelessWidget {
  const _DietPlanCard({required this.plan, required this.onTap});

  final DietPlanModel plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if (plan.traineeName != null) subtitleParts.add('Trainee: ${plan.traineeName}');
    if (plan.trainerName != null) subtitleParts.add('Trainer: ${plan.trainerName}');

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(plan.status == 'completed' ? '✓' : '•'),
        ),
        title: Text(plan.title),
        subtitle: Text(subtitleParts.isEmpty ? ' ' : subtitleParts.join('   ·   ')),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (plan.caloriesTarget != null) Text('${plan.caloriesTarget} kcal'),
            Text('${plan.meals.length} meals', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
