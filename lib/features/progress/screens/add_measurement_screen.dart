import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../providers/progress_providers.dart';

class AddMeasurementScreen extends ConsumerStatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  ConsumerState<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends ConsumerState<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _weightCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _thighsCtrl = TextEditingController();

  DateTime? _date;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _hipsCtrl.dispose();
    _armsCtrl.dispose();
    _thighsCtrl.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(progressActionsProvider.notifier).addMeasurement(
          weight: _parse(_weightCtrl),
          chest: _parse(_chestCtrl),
          waist: _parse(_waistCtrl),
          hips: _parse(_hipsCtrl),
          arms: _parse(_armsCtrl),
          thighs: _parse(_thighsCtrl),
          measuredAt: _date,
        );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Measurements saved')));
    } else {
      final err = ref.read(progressActionsProvider).whenOrNull(error: (e, _) => e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.messageFromError(err ?? Exception('Failed')))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(progressActionsProvider);

    InputDecoration dec(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder());

    return Scaffold(
      appBar: AppBar(title: const Text('Add Measurements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(child: _numField(_weightCtrl, dec('Weight (kg)'))),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_chestCtrl, dec('Chest (cm)'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _numField(_waistCtrl, dec('Waist (cm)'))),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_hipsCtrl, dec('Hips (cm)'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _numField(_armsCtrl, dec('Arms (cm)'))),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_thighsCtrl, dec('Thighs (cm)'))),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(_date == null ? 'Today' : _date!.toLocal().toString().split(' ').first),
                trailing: OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date ?? now,
                      firstDate: DateTime(now.year - 5),
                      lastDate: now,
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  icon: const Icon(Icons.date_range),
                  label: const Text('Pick'),
                ),
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
        if (d == null || d < 0) return 'Invalid number';
        return null;
      },
    );
  }
}
