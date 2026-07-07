import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PreloaderScreen extends StatefulWidget {
  const PreloaderScreen({super.key});

  @override
  State<PreloaderScreen> createState() => _PreloaderScreenState();
}

class _PreloaderScreenState extends State<PreloaderScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeController.forward();
    _progressController.forward().then((_) {
      // Transition to home page after animation finishes
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          context.go('/home');
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo & Title fading/scaling in
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SAFRA',
                          style: AppTypography.displayLarge(color: AppColors.ink).copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Progress Bar
            Container(
              width: 180,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(1.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressController.value,
                    child: Container(
                      color: AppColors.amber,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Tagline
            Text(
              'DRIVE BEYOND',
              style: AppTypography.monoStyle(color: AppColors.inkMuted, size: 9).copyWith(
                letterSpacing: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
