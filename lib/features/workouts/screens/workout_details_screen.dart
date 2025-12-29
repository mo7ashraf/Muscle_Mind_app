import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/exercise_model.dart';
import '../providers/workout_providers.dart';

class WorkoutDetailsScreen extends ConsumerWidget {
  const WorkoutDetailsScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isTrainer = auth.user?.role == 'trainer';

    final asyncWorkout = ref.watch(workoutDetailsProvider(workoutId));

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      floatingActionButton: isTrainer
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addExercise, arguments: workoutId),
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            )
          : null,
      body: asyncWorkout.when(
        data: (w) {
          final dateText = w.scheduledDate != null ? DateFormat('yyyy-MM-dd').format(w.scheduledDate!) : 'Not scheduled';
          final status = w.completed ? 'Completed' : 'Pending';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(w.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('$dateText • $status', style: Theme.of(context).textTheme.bodyMedium),
              if (w.description != null && w.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(w.description!),
              ],
              const SizedBox(height: 16),
              Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (w.exercises.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No exercises yet')))
              else
                ...w.exercises.map((e) => _ExerciseCard(item: e)),
              const SizedBox(height: 16),
              if (!isTrainer && !w.completed)
                ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await ref.read(workoutActionsProvider.notifier).markCompleted(workoutId);
                    if (!context.mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as completed')));
                    } else {
                      final err = ref.read(workoutActionsProvider).error;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.messageFromError(err ?? 'Error'))));
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as completed'),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ApiService.messageFromError(e))),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.item});

  final ExerciseModel item;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (item.sets != null) parts.add('Sets: ${item.sets}');
    if (item.reps != null) parts.add('Reps: ${item.reps}');
    if (item.restTime != null) parts.add('Rest: ${item.restTime}s');
    final subtitle = parts.isEmpty ? null : parts.join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.sports_mma),
        title: Text(item.name),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: item.videoUrl != null ? const Icon(Icons.play_circle_outline) : null,
        onTap: item.videoUrl == null
            ? null
            : () {
                // Keeping it simple: just copy link dialog for now
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Video URL'),
                    content: Text(item.videoUrl!),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                    ],
                  ),
                );
              },
      ),
    );
  }
}
