import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_service.dart';
import '../providers/progress_providers.dart';

class AddProgressScreen extends ConsumerStatefulWidget {
  const AddProgressScreen({super.key});

  @override
  ConsumerState<AddProgressScreen> createState() => _AddProgressScreenState();
}

class _AddProgressScreenState extends ConsumerState<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _takenAt;
  XFile? _front;
  XFile? _side;
  XFile? _back;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(void Function(XFile) setFile) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setFile(x);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    double? weight;
    if (_weightCtrl.text.trim().isNotEmpty) {
      weight = double.tryParse(_weightCtrl.text.trim());
    }

    final ok = await ref.read(progressActionsProvider.notifier).uploadProgress(
          frontPath: _front?.path,
          sidePath: _side?.path,
          backPath: _back?.path,
          weight: weight,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          takenAt: _takenAt,
        );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress saved')));
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

    return Scaffold(
      appBar: AppBar(title: const Text('Add Progress Photos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _ImagePickerCard(
                title: 'Front',
                file: _front,
                onPick: () => _pick((x) => setState(() => _front = x)),
              ),
              const SizedBox(height: 12),
              _ImagePickerCard(
                title: 'Side',
                file: _side,
                onPick: () => _pick((x) => setState(() => _side = x)),
              ),
              const SizedBox(height: 12),
              _ImagePickerCard(
                title: 'Back',
                file: _back,
                onPick: () => _pick((x) => setState(() => _back = x)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final d = double.tryParse(v.trim());
                  if (d == null || d <= 0) return 'Enter a valid weight';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(_takenAt == null ? 'Today' : _takenAt!.toLocal().toString().split(' ').first),
                trailing: OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _takenAt ?? now,
                      firstDate: DateTime(now.year - 5),
                      lastDate: now,
                    );
                    if (picked != null) setState(() => _takenAt = picked);
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
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({required this.title, required this.file, required this.onPick});

  final String title;
  final XFile? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black12,
              ),
              child: file == null
                  ? const Icon(Icons.image_outlined)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(file!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(file?.name ?? 'No image selected', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onPick,
              child: const Text('Choose'),
            )
          ],
        ),
      ),
    );
  }
}
