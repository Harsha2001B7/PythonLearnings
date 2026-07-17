import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../controllers/auth_controller.dart';

/// Splash Screen that shows the Falcon View brand identity while
/// the auth controller initialises the session in the background.
/// Uses a minimum timer delay (1500ms) to ensure smooth animations
/// and avoid race conditions if the auth state resolves instantly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  bool _minimumDelayPassed = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _animCtrl.forward();

    // Force a transition to check current/future state after a minimum delay
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _minimumDelayPassed = true);
      _checkAndNavigate(ref.read(authControllerProvider));
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _checkAndNavigate(AuthState state) {
    if (!_minimumDelayPassed) return;

    if (state is AuthAuthenticated) {
      final destination = state.user.isAdmin ? AppRoute.adminHome : AppRoute.home;
      context.go(destination);
    } else if (state is AuthUnauthenticated) {
      context.go(AppRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (mounted) {
        _checkAndNavigate(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ─── Background radial glow ─────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0),
                  radius: 1.2,
                  colors: [
                    AppColors.orange.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ─── Center Falcon Logo ──────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: SizedBox(
                  width: 280,
                  child: Image.asset(
                    'lib/assets/falconviewLogotransparentbackground.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
