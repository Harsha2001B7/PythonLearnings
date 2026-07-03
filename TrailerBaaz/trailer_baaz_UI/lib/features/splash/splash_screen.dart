import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/app_theme.dart';
import '../../core/di/locator.dart';
import '../../core/navigation/navigation_service.dart';
import '../../shared/animations/animations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _glowController;
  late final AnimationController _textController;
  late final AnimationController _buttonController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoGlow;

  late final FadeSlideAnimations _wordmarkEntrance;
  late final FadeSlideAnimations _taglineEntrance;
  late final FadeSlideAnimations _googleButtonEntrance;
  late final FadeSlideAnimations _guestButtonEntrance;

  bool _buttonsReady = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Phase 1: the TB logo emerges from the black center, scaling up smoothly.
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Phase 2: a restrained cinematic red pulse blooms once, then settles.
    _logoGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 0.36,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 42,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.36,
          end: 0.08,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 58,
      ),
    ]).animate(_glowController);

    // Phase 3: the TrailerBaaz wordmark rises subtly after the mark settles.
    _wordmarkEntrance = FadeSlideAnimations.fromInterval(
      parent: _textController,
      interval: const Interval(0.0, 0.72, curve: AppMotion.cinematic),
    );

    // Phase 4: the tagline follows with a small delay and matching upward drift.
    _taglineEntrance = FadeSlideAnimations.fromInterval(
      parent: _textController,
      interval: const Interval(0.26, 1.0, curve: AppMotion.cinematic),
    );

    // Phase 5: the Google button enters first from below.
    _googleButtonEntrance = FadeSlideAnimations.fromInterval(
      parent: _buttonController,
      interval: const Interval(0.0, 0.68, curve: AppMotion.cinematic),
      slideBegin: AppMotion.slideUpMedium,
    );

    // Phase 6: the guest button follows 100-150ms later for a premium stagger.
    _guestButtonEntrance = FadeSlideAnimations.fromInterval(
      parent: _buttonController,
      interval: const Interval(0.18, 0.92, curve: AppMotion.cinematic),
      slideBegin: AppMotion.slideUpMedium,
    );

    _runSequence();
  }

  void _runSequence() async {
    // Start on a completely black frame before any branded element appears.
    await Future.delayed(const Duration(milliseconds: 360));
    if (!mounted) return;

    // Bring the TB mark in from the center.
    await _logoController.forward();
    if (!mounted) return;

    // Pulse the red glow once while the title begins its cinematic rise.
    _glowController.forward();
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await _textController.forward();

    // Let the brand moment breathe, then reveal the actions one after another.
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await _buttonController.forward();
    if (!mounted) return;
    setState(() => _buttonsReady = true);
  }

  @override
  void dispose() {
    try {
      _logoController.dispose();
      _glowController.dispose();
      _textController.dispose();
      _buttonController.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _navigateHome() {
    locator<NavigationService>().replaceWithShell(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Animated Hero Logo
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _glowController]),
                builder: (context, child) {
                  return FadeScaleEntrance(
                    opacity: _logoFade,
                    scale: _logoScale,
                    child: _Logo(glowOpacity: _logoGlow.value),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Tagline & Wordmark
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Column(
                    children: [
                      FadeSlideEntrance.from(
                        animations: _wordmarkEntrance,
                        child: const _Wordmark(),
                      ),
                      const SizedBox(height: 12),
                      FadeSlideEntrance.from(
                        animations: _taglineEntrance,
                        child: Text(
                          'Discover the Next Blockbuster.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(flex: 4),

              // Buttons
              AnimatedBuilder(
                animation: _buttonController,
                builder: (context, child) {
                  return AbsorbPointer(
                    absorbing: !_buttonsReady,
                    child: AnimatedOpacity(
                      opacity: _buttonController.value == 0 ? 0.0 : 1.0,
                      duration: AppMotion.buttonColumnOpacity,
                      curve: AppMotion.cinematic,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeSlideEntrance.from(
                            animations: _googleButtonEntrance,
                            child: PressScaleButton(
                              onTap: _navigateHome,
                              child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/google.svg',
                                        height: 22,
                                        width: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          FadeSlideEntrance.from(
                            animations: _guestButtonEntrance,
                            child: PressScaleButton(
                              onTap: _navigateHome,
                              child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Browse as Guest',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _Logo extends StatelessWidget {
//   const _Logo({required this.glowOpacity});

//   final double glowOpacity;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Subtle ambient red glow behind logo that lands smoothly
//         Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.accent.withValues(alpha: glowOpacity),
//                 blurRadius: 70,
//                 spreadRadius: 15,
//               ),
//             ],
//           ),
//         ),
//         // The hero PNG logo, no container constraints, just the image itself
//         Image.asset(
//           'assets/images/app_icon.png',
//           width: 120,
//           fit: BoxFit.contain,
//           filterQuality: FilterQuality.high,
//         ),
//       ],
//     );
//   }
// }

class _Logo extends StatelessWidget {
  const _Logo({required this.glowOpacity});

  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Native Flutter glow only: a soft red bloom that pulses once and recedes.
        AnimatedOpacity(
          opacity: glowOpacity.clamp(0.0, 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accent.withValues(alpha: 0.32),
                  AppTheme.accent.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.28),
                  blurRadius: 72,
                  spreadRadius: 12,
                ),
              ],
            ),
          ),
        ),
        Image.asset(
          'assets/images/TrailerBaaz6.png',
          width: 120,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Trailer',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: Colors.white,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Text(
              'Baaz',
              style: style.copyWith(
                color: AppTheme.accent.withValues(alpha: 0.4),
                shadows: [
                  Shadow(
                    color: AppTheme.accent.withValues(alpha: 0.8),
                    blurRadius: 12,
                  ),
                  Shadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
            // Sharp text
            Text(
              'Baaz',
              style: style.copyWith(
                color: AppTheme.accent,
                shadows: [
                  Shadow(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
