import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _classCodeController = TextEditingController();

  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _classCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    ref.read(authNotifierProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
          classCode: _classCodeController.text.trim().isEmpty ? null : _classCodeController.text,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () {
            ref.read(authNotifierProvider.notifier).clearError();
            context.go('/login');
          },
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Join Probon',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Start collaborating, building, and earning achievements',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error Banner if registration fails
                    if (authState.hasError)
                      AuthErrorBanner(
                        message: authState.errorMessage!,
                        onDismiss: () => ref.read(authNotifierProvider.notifier).clearError(),
                      ),

                    // Role Selector (Student / Teacher)
                    RoleSelector(
                      selectedRole: _selectedRole,
                      onRoleChanged: (newRole) {
                        setState(() {
                          _selectedRole = newRole;
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // Full Name Field
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Aryan Patel',
                      prefixIcon: LucideIcons.user,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Username Field
                    AuthTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'aryan_dev',
                      prefixIcon: LucideIcons.atSign,
                      validator: Validators.validateUsername,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'aryan@example.com',
                      prefixIcon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Min. 8 chars, Aa, 1, #',
                      prefixIcon: LucideIcons.lock,
                      isPassword: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // Optional Class Code
                    AuthTextField(
                      controller: _classCodeController,
                      label: 'Class Code (Optional)',
                      hint: 'e.g. CS101-2026',
                      prefixIcon: LucideIcons.key,
                      textInputAction: TextInputAction.done,
                      validator: Validators.validateClassCode,
                      onFieldSubmitted: (_) => _handleRegister(),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleRegister,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                    const SizedBox(height: 20),

                    // Switch to Sign In
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        InkWell(
                          onTap: () {
                            ref.read(authNotifierProvider.notifier).clearError();
                            context.go('/login');
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
