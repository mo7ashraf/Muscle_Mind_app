import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../providers/workout_providers.dart';

class CreateWorkoutScreen extends ConsumerStatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  ConsumerState<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends ConsumerState<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _traineeIdCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _scheduled;

  @override
  void dispose() {
    _traineeIdCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  int? _parseInt(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduled ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _scheduled = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final traineeId = _parseInt(_traineeIdCtrl.text);
    if (traineeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid trainee id')));
      return;
    }

    final ok = await ref.read(workoutActionsProvider.notifier).createWorkout(
          traineeId: traineeId,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          scheduledDate: _scheduled,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout created')));
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
      appBar: AppBar(title: const Text('Create Workout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _traineeIdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Trainee ID'),
              validator: (v) => (_parseInt(v ?? '') == null) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(_scheduled == null ? 'Pick scheduled date (optional)' : 'Scheduled: ${_scheduled!.toIso8601String().split('T').first}'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: actionState.isLoading ? null : _submit,
              child: actionState.isLoading ? const CircularProgressIndicator() : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
