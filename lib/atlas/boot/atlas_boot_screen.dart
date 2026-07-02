import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/atlas_navigation_shell.dart';
import '../../screens/auth/login_screen.dart';
import '../../security/auth_provider.dart';
import '../../theme/atlas_animation.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_constants.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import 'atlas_boot_controller.dart';
import 'atlas_boot_logo.dart';

class AtlasBootScreen extends StatefulWidget {
  const AtlasBootScreen({super.key});

  @override
  State<AtlasBootScreen> createState() => _AtlasBootScreenState();
}

class _AtlasBootScreenState extends State<AtlasBootScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  String _status = AtlasConstants.initializing;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: AtlasAnimation.splash,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: AtlasAnimation.entranceCurve,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: AtlasAnimation.entranceCurve,
      ),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: AtlasAnimation.gentleCurve,
    );

    _startBoot();
  }

  Future<void> _startBoot() async {
    final authProvider = context.read<AuthProvider>();

    _introController.forward();

    await _updateStatus(AtlasConstants.preparing, 700);
    await _updateStatus(AtlasConstants.analyzing, 700);
    await _updateStatus('Checking Atlas Account...', 700);

    await authProvider.initialize();

    await _updateStatus('Loading Collector DNA...', 700);
    await _updateStatus('Restoring Vault Memory...', 700);

    await const AtlasBootController().initialize();

    await _updateStatus(AtlasConstants.ready, 700);

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => authProvider.isLoggedIn
            ? const AtlasNavigationShell()
            : const LoginScreen(),
      ),
    );
  }

  Future<void> _updateStatus(
      String status,
      int delayMs,
      ) async {
    await Future.delayed(
      Duration(milliseconds: delayMs),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _status = status;
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.midnight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AtlasSpacing.xl),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AtlasBootLogo(
                      pulse: _pulseAnimation,
                    ),
                    const SizedBox(height: AtlasSpacing.xl),
                    Text(
                      AtlasConstants.platformName.toUpperCase(),
                      style: AtlasTypography.displayLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      AtlasConstants.platformSubtitle,
                      textAlign: TextAlign.center,
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.atlasSilver,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xxl),
                    AnimatedSwitcher(
                      duration: AtlasAnimation.standard,
                      child: Text(
                        _status,
                        key: ValueKey(_status),
                        textAlign: TextAlign.center,
                        style: AtlasTypography.label.copyWith(
                          color: AtlasColors.intelligenceBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const SizedBox(
                      width: 190,
                      child: LinearProgressIndicator(),
                    ),
                    const SizedBox(height: AtlasSpacing.xl),
                    Text(
                      AtlasConstants.poweredBy,
                      style: AtlasTypography.bodySmall,
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