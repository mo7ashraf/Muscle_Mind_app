import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_routes.dart';
import '../providers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();

  // trainer fields
  final _specialization = TextEditingController();
  final _experienceYears = TextEditingController();
  final _certification = TextEditingController();
  final _bio = TextEditingController();

  // trainee fields
  final _trainerId = TextEditingController();
  final _currentWeight = TextEditingController();
  final _targetWeight = TextEditingController();
  final _height = TextEditingController();
  final _age = TextEditingController();

  String _role = 'trainee';
  String? _gender;
  String _goal = 'maintenance';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _password2.dispose();
    _specialization.dispose();
    _experienceYears.dispose();
    _certification.dispose();
    _bio.dispose();
    _trainerId.dispose();
    _currentWeight.dispose();
    _targetWeight.dispose();
    _height.dispose();
    _age.dispose();
    super.dispose();
  }

  int? _toInt(String v) => int.tryParse(v.trim());
  double? _toDouble(String v) => double.tryParse(v.trim());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authControllerProvider.notifier).register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          passwordConfirmation: _password2.text,
          role: _role,
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),

          specialization: _role == 'trainer' && _specialization.text.trim().isNotEmpty
              ? _specialization.text.trim()
              : null,
          experienceYears: _role == 'trainer' ? _toInt(_experienceYears.text) : null,
          certification: _role == 'trainer' && _certification.text.trim().isNotEmpty
              ? _certification.text.trim()
              : null,
          bio: _role == 'trainer' && _bio.text.trim().isNotEmpty ? _bio.text.trim() : null,

          trainerId: _role == 'trainee' ? _toInt(_trainerId.text) : null,
          currentWeight: _role == 'trainee' ? _toDouble(_currentWeight.text) : null,
          targetWeight: _role == 'trainee' ? _toDouble(_targetWeight.text) : null,
          height: _role == 'trainee' ? _toDouble(_height.text) : null,
          age: _role == 'trainee' ? _toInt(_age.text) : null,
          gender: _role == 'trainee' ? _gender : null,
          goal: _role == 'trainee' ? _goal : null,
        );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacementNamed(
        _role == 'trainer' ? AppRoutes.trainerHome : AppRoutes.traineeHome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'trainee', child: Text('Trainee')),
                    DropdownMenuItem(value: 'trainer', child: Text('Trainer')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'trainee'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Email is required';
                    if (!s.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) {
                    if ((v ?? '').length < 8) return 'Min 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password2,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  validator: (v) {
                    if ((v ?? '') != _password.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                if (_role == 'trainer') ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _specialization,
                    decoration: const InputDecoration(labelText: 'Specialization (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _experienceYears,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Experience years (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _certification,
                    decoration: const InputDecoration(labelText: 'Certification (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bio,
                    decoration: const InputDecoration(labelText: 'Bio (optional)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),
                ],

                if (_role == 'trainee') ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _trainerId,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Trainer ID (optional)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender (optional)'),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _goal,
                    decoration: const InputDecoration(labelText: 'Goal'),
                    items: const [
                      DropdownMenuItem(value: 'weight_loss', child: Text('Weight loss')),
                      DropdownMenuItem(value: 'muscle_gain', child: Text('Muscle gain')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                    ],
                    onChanged: (v) => setState(() => _goal = v ?? 'maintenance'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _currentWeight,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Current weight (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _targetWeight,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Target weight (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _height,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _age,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age (optional)'),
                  ),
                  const SizedBox(height: 18),
                ],

                if (state.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(state.error!),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
