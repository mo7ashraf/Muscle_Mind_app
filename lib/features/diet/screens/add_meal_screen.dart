import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../providers/diet_providers.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key, required this.dietPlanId});

  final int dietPlanId;

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _cCtrl = TextEditingController();
  final _fCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    _calCtrl.dispose();
    _pCtrl.dispose();
    _cCtrl.dispose();
    _fCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  int? _parseInt(String t) {
    final s = t.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  double? _parseDouble(String t) {
    final s = t.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(dietActionsProvider.notifier).addMeal(
          dietPlanId: widget.dietPlanId,
          name: _nameCtrl.text.trim(),
          time: _timeCtrl.text.trim().isEmpty ? null : _timeCtrl.text.trim(),
          calories: _parseInt(_calCtrl.text),
          proteins: _parseDouble(_pCtrl.text),
          carbs: _parseDouble(_cCtrl.text),
          fats: _parseDouble(_fCtrl.text),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal added')));
    } else {
      final err = ref.read(dietActionsProvider).whenOrNull(error: (e, _) => e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.messageFromError(err ?? Exception('Failed')))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(dietActionsProvider);

    InputDecoration dec(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder());

    return Scaffold(
      appBar: AppBar(title: const Text('Add Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: dec('Meal name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeCtrl,
                decoration: dec('Time (e.g. 08:00 or Breakfast)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _numField(_calCtrl, dec('Calories'))),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_pCtrl, dec('Proteins (g)'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _numField(_cCtrl, dec('Carbs (g)'))),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_fCtrl, dec('Fats (g)'))),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: dec('Description'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: actions.isLoading ? null : _submit,
                icon: actions.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numField(TextEditingController controller, InputDecoration decoration) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: decoration,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        final d = double.tryParse(v.trim());
        if (d == null || d < 0) return 'Invalid';
        return null;
      },
    );
  }
}
