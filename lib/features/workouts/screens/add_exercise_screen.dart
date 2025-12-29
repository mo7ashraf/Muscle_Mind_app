import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../providers/workout_providers.dart';

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _restCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _restCtrl.dispose();
    _notesCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  int? _parseInt(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(workoutActionsProvider.notifier).addExercise(
          workoutId: widget.workoutId,
          name: _nameCtrl.text.trim(),
          sets: _parseInt(_setsCtrl.text),
          reps: _parseInt(_repsCtrl.text),
          restTime: _parseInt(_restCtrl.text),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          videoUrl: _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exercise added')));
      Navigator.of(context).pop();
    } else {
      final e = ref.read(workoutActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.messageFromError(e ?? 'Error'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(workoutActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Exercise')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Exercise name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _restCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rest time (sec)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _videoCtrl,
              decoration: const InputDecoration(labelText: 'Video URL (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: actionState.isLoading ? null : _submit,
              child: actionState.isLoading ? const CircularProgressIndicator() : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
