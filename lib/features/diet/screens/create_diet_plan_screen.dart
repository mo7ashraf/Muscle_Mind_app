import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../providers/diet_providers.dart';

class CreateDietPlanScreen extends ConsumerStatefulWidget {
  const CreateDietPlanScreen({super.key});

  @override
  ConsumerState<CreateDietPlanScreen> createState() => _CreateDietPlanScreenState();
}

class _CreateDietPlanScreenState extends ConsumerState<CreateDietPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _calCtrl = TextEditingController();

  int? _selectedTraineeId;
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  int? _parseInt(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTraineeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a trainee')));
      return;
    }

    final ok = await ref.read(dietActionsProvider.notifier).createPlan(
          traineeId: _selectedTraineeId!,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          caloriesTarget: _parseInt(_calCtrl.text),
          startDate: _start,
          endDate: _end,
        );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diet plan created')));
    } else {
      final err = ref.read(dietActionsProvider).whenOrNull(error: (e, _) => e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.messageFromError(err ?? Exception('Failed')))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final traineesAsync = ref.watch(trainerTraineesListProvider);
    final actions = ref.watch(dietActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Diet Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              traineesAsync.when(
                data: (list) {
                  final items = list.map((t) {
                    final traineeId = (t['id'] as num?)?.toInt() ?? 0;
                    final user = t['user'] as Map<String, dynamic>?;
                    final name = (user?['name'] ?? 'Trainee') as String;
                    return DropdownMenuItem<int>(value: traineeId, child: Text('$name (#$traineeId)'));
                  }).toList();

                  return DropdownButtonFormField<int>(
                    value: _selectedTraineeId,
                    items: items,
                    onChanged: (v) => setState(() => _selectedTraineeId = v),
                    decoration: const InputDecoration(
                      labelText: 'Trainee',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null ? 'Choose a trainee' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(ApiService.messageFromError(e)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories target (kcal)', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return 'Invalid calories';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DatePickTile(
                      title: 'Start date',
                      value: _start,
                      onPick: (d) => setState(() => _start = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickTile(
                      title: 'End date',
                      value: _end,
                      onPick: (d) => setState(() => _end = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: actions.isLoading ? null : _submit,
                icon: actions.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Create'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickTile extends StatelessWidget {
  const _DatePickTile({required this.title, required this.value, required this.onPick});

  final String title;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 2),
        );
        onPick(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: title, border: const OutlineInputBorder()),
        child: Text(value == null ? '-' : value!.toLocal().toString().split(' ').first),
      ),
    );
  }
}
