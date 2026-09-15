import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/atlas_navigation_shell.dart';
import '../../security/auth_provider.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_form_field.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

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
        MaterialPageRoute<void>(builder: (_) => const AtlasNavigationShell()),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Atlas could not sign you in. Check your email and password, then try again.',
          ),
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

  void _togglePasswordVisibility() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _openRegister() {
    if (_isLoading) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  void _openForgotPassword() {
    if (_isLoading) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _continueAsGuest() {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const AtlasNavigationShell()),
    );
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email.';
    }

    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
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
                accentColor: AtlasColors.vaultGold,
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AtlasSectionHeader(
                          title: 'Welcome to Atlas',
                          subtitle:
                              'Sign in to access your collector profile, vault, and Atlas intelligence.',
                          icon: Icons.shield_rounded,
                          accentColor: AtlasColors.vaultGold,
                          titleStyle: AtlasTypography.headingLarge,
                        ),
                        const SizedBox(height: AtlasSpacing.lg),
                        const AtlasInfoBanner(
                          icon: Icons.lock_outline_rounded,
                          title: 'Secure Sign In',
                          message:
                              'Your account credentials are used only to authenticate your Atlas account.',
                        ),
                        const SizedBox(height: AtlasSpacing.lg),
                        AtlasFormField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: AtlasSpacing.md),
                        AtlasFormField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          enabled: !_isLoading,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.password],
                          validator: _validatePassword,
                          onFieldSubmitted: (_) {
                            _signIn();
                          },
                          suffixIcon: IconButton(
                            tooltip: _isPasswordVisible
                                ? 'Hide password'
                                : 'Show password',
                            onPressed: _isLoading
                                ? null
                                : _togglePasswordVisibility,
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: AtlasSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isLoading ? null : _signIn,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: Text(_isLoading ? 'Signing In' : 'Sign In'),
                          ),
                        ),
                        const SizedBox(height: AtlasSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _openRegister,
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Create Account'),
                          ),
                        ),
                        const SizedBox(height: AtlasSpacing.sm),
                        TextButton(
                          onPressed: _isLoading ? null : _openForgotPassword,
                          child: const Text('Forgot Password?'),
                        ),
                        const SizedBox(height: AtlasSpacing.md),
                        Divider(
                          color: AtlasColors.textSecondary.withValues(
                            alpha: 0.18,
                          ),
                        ),
                        const SizedBox(height: AtlasSpacing.sm),
                        TextButton.icon(
                          onPressed: _isLoading ? null : _continueAsGuest,
                          icon: const Icon(Icons.person_outline_rounded),
                          label: const Text('Continue as Guest'),
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
      ),
    );
  }
}
