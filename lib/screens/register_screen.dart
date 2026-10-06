import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../constants/app_strings.dart';
import '../utils/validators.dart';
import '../utils/result.dart';
import '../router/app_router.dart';
import '../models/models.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisC = TextEditingController();
  final _nameC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _selectedKelas = AppStrings.kelasList.first;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulasi network
    if (!mounted) return;

    final result = context.read<AuthProvider>().register(
      nis: _nisC.text,
      name: _nameC.text,
      kelas: _selectedKelas,
      password: _passwordC.text,
    );
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result is Success<UserModel>) {
      context.go(AppRoutes.home);
    } else if (result is Failure<UserModel>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.terminal, size: 56, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(AppStrings.appName,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(AppStrings.createAccount,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(AppStrings.register,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nisC,
                            validator: Validators.validateNIS,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: AppStrings.nisLabel,
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameC,
                            validator: Validators.validateName,
                            decoration: const InputDecoration(
                              labelText: AppStrings.nameLabel,
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedKelas,
                            decoration: InputDecoration(
                              labelText: AppStrings.kelasLabel,
                              prefixIcon: const Icon(Icons.class_outlined),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300)),
                            ),
                            items: AppStrings.kelasList
                                .map((k) =>
                                    DropdownMenuItem(value: k, child: Text(k)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedKelas = v!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordC,
                            obscureText: _obscurePassword,
                            validator: Validators.validatePassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.passwordLabel,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordC,
                            obscureText: _obscureConfirm,
                            validator: (v) => Validators.validateConfirmPassword(v, _passwordC.text),
                            decoration: InputDecoration(
                              labelText: AppStrings.confirmPasswordLabel,
                              prefixIcon: const Icon(Icons.lock_clock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            height: 52,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _register,
                                    child: const Text(AppStrings.registerNow),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(AppStrings.hasAccount),
                              GestureDetector(
                                onTap: () => context.pop(), // Pop to go back to login
                                child: const Text(AppStrings.login,
                                    style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
