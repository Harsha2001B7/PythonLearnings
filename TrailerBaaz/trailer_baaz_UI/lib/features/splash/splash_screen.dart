import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/app_theme.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _buttonController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoGlow;

  late final Animation<double> _wordmarkFade;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200), // Calm, luxurious entrance
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Logo starts slightly larger (1.15) and settles to 1.0 with easeOutCubic
    _logoScale = Tween<double>(begin: 1.15, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Fade in logo over the first 50% of the animation
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Glow starts intense (0.7) and reduces to very subtle (0.15) as it lands
    _logoGlow = Tween<double>(begin: 0.7, end: 0.15).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Wordmark staggers in first
    _wordmarkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _wordmarkSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline staggers in next
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Buttons slide up with a gentle fade and spring-like easing (easeOutQuart for premium feel)
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutQuart),
    );

    _runSequence();
  }

  void _runSequence() async {
    // 1. Initial pause: Screen is almost completely black.
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // 2. Logo entrance and landing
    await _logoController.forward();
    if (!mounted) return;

    // 3. Texts stagger in after logo has completed entrance
    _textController.forward();
    
    // 4. Wait for text to finish, then short pause before buttons
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // 5. Buttons enter
    _buttonController.forward();
  }

  @override
  void dispose() {
    try {
      _logoController.dispose();
      _textController.dispose();
      _buttonController.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _navigateHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AppShell();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Premium shared-axis / scale fade transition
          final fade = Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

          final scaleIn = Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          // The outgoing page fades out and scales up slightly
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scaleIn, child: child),
          );
        },
      ),
    );
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
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _Logo(glowOpacity: _logoGlow.value),
                    ),
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
                      FadeTransition(
                        opacity: _wordmarkFade,
                        child: SlideTransition(
                          position: _wordmarkSlide,
                          child: const _Wordmark(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: SlideTransition(
                          position: _taglineSlide,
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
                  return FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ScaleButton(
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

                          const SizedBox(height: 16),

                          _ScaleButton(
                            onTap: _navigateHome,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
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

class _Logo extends StatelessWidget {
  const _Logo({required this.glowOpacity});

  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle ambient red glow behind logo that lands smoothly
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withValues(alpha: glowOpacity),
                blurRadius: 70,
                spreadRadius: 15,
              ),
            ],
          ),
        ),
        // The hero PNG logo, no container constraints, just the image itself
        Image.asset(
          'assets/images/app_icon.png',
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

class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleButton({required this.child, required this.onTap});

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
