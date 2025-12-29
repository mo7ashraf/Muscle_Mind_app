import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/workout_model.dart';
import '../providers/workout_providers.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isTrainer = auth.user?.role == 'trainer';

    final workoutsAsync = ref.watch(workoutsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      floatingActionButton: isTrainer
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createWorkout),
              icon: const Icon(Icons.add),
              label: const Text('Create Workout'),
            )
          : null,
      body: workoutsAsync.when(
        data: (paged) {
          final items = paged.data;
          if (items.isEmpty) {
            return const Center(child: Text('No workouts yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) => _WorkoutCard(item: items[idx]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ApiService.messageFromError(e))),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.item});

  final WorkoutModel item;

  @override
  Widget build(BuildContext context) {
    final dateText = item.scheduledDate != null ? DateFormat('yyyy-MM-dd').format(item.scheduledDate!) : 'Not scheduled';
    final status = item.completed ? 'Completed' : 'Pending';

    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.workoutDetails, arguments: item.id),
        leading: CircleAvatar(
          child: Icon(item.completed ? Icons.check : Icons.fitness_center),
        ),
        title: Text(item.title),
        subtitle: Text('$dateText • $status'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
