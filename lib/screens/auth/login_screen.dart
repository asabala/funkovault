import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/atlas_navigation_shell.dart';
import '../../security/auth_provider.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthProvider>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AtlasNavigationShell(),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your email.';
    }

    if (!value.contains('@')) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AtlasSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AtlasGlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        size: 72,
                        color: AtlasColors.vaultGold,
                      ),
                      const SizedBox(height: AtlasSpacing.lg),
                      Text(
                        'ATLAS',
                        textAlign: TextAlign.center,
                        style: AtlasTypography.headingLarge,
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      Text(
                        'Collector Intelligence Platform',
                        textAlign: TextAlign.center,
                        style: AtlasTypography.bodyMedium.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.xl),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: AtlasSpacing.md),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: _validatePassword,
                        onFieldSubmitted: (_) => _signIn(),
                      ),
                      const SizedBox(height: AtlasSpacing.md),
                      CheckboxListTile(
                        value: _rememberMe,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                          setState(() {
                            _rememberMe = value ?? true;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Remember Me'),
                      ),
                      const SizedBox(height: AtlasSpacing.md),
                      FilledButton(
                        onPressed: _isLoading ? null : _signIn,
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Sign In'),
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Create Account'),
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                      const Divider(height: 32),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const AtlasNavigationShell(),
                            ),
                          );
                        },
                        child: const Text('Continue as Guest'),
                      ),
                      const SizedBox(height: AtlasSpacing.md),
                      Text(
                        'Powered by Atlas Core',
                        textAlign: TextAlign.center,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}