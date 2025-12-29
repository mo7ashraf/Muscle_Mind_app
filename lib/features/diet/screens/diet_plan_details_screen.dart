import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/diet_plan_model.dart';
import '../models/meal_model.dart';
import '../providers/diet_providers.dart';

class DietPlanDetailsScreen extends ConsumerWidget {
  const DietPlanDetailsScreen({super.key, required this.dietPlanId});

  final int dietPlanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isTrainer = auth.user?.role == 'trainer';

    final planAsync = ref.watch(dietPlanProvider(dietPlanId));
    final dateFmt = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        actions: [
          if (isTrainer)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete plan?'),
                    content: const Text('This will remove the plan and its meals.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm != true) return;

                final ok = await ref.read(dietActionsProvider.notifier).deletePlan(dietPlanId);
                if (!context.mounted) return;
                if (ok) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Deleted')));
                } else {
                  final err = ref.read(dietActionsProvider).whenOrNull(error: (e, _) => e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ApiService.messageFromError(err ?? Exception('Failed')))),
                  );
                }
              },
            ),
        ],
      ),
      floatingActionButton: isTrainer
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.addMeal, arguments: dietPlanId);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add meal'),
            )
          : null,
      body: planAsync.when(
        data: (plan) => _Body(plan: plan, dateFmt: dateFmt),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ApiService.messageFromError(e))),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.plan, required this.dateFmt});

  final DietPlanModel plan;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    final start = plan.startDate == null ? '-' : dateFmt.format(plan.startDate!);
    final end = plan.endDate == null ? '-' : dateFmt.format(plan.endDate!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Status: ${plan.status}'),
                if (plan.caloriesTarget != null) Text('Calories target: ${plan.caloriesTarget} kcal'),
                const SizedBox(height: 4),
                Text('Dates: $start → $end'),
                if (plan.description != null && plan.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(plan.description!.trim()),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Meals', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (plan.meals.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No meals yet.')))
        else
          ...plan.meals.map((m) => _MealCard(meal: m)),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MealModel meal;

  @override
  Widget build(BuildContext context) {
    String fmt(double? v) => v == null ? '-' : v.toStringAsFixed(0);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu),
        title: Text(meal.name),
        subtitle: Text(
          [
            if (meal.time != null && meal.time!.trim().isNotEmpty) 'Time: ${meal.time}',
            if (meal.calories != null) 'Calories: ${meal.calories}',
            'P/C/F: ${fmt(meal.proteins)}/${fmt(meal.carbs)}/${fmt(meal.fats)}',
          ].join('   ·   '),
        ),
      ),
    );
  }
}
