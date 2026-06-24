import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../navigation/bottom_navigation_screen.dart';
// import 'phone_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _onGoogleLogin(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();
      if (!context.mounted) return;

      final account = await googleSignIn.authenticate();
      if (!context.mounted) return;

      _showSnackBar(context, 'Welcome ${account.displayName ?? account.email}');

      // TODO: Send token to FastAPI later

      _openApp(context);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Google sign-in failed.');

      debugPrint(e.toString());
    }
  }

  // Future<void> _onFacebookLogin(BuildContext context) async {
  //   try {
  //     final result = await FacebookAuth.instance.login();
  //     if (!context.mounted) return;

  //     if (result.status == LoginStatus.success) {
  //       _showSnackBar(context, 'Facebook login successful');

  //       // TODO: Send access token to FastAPI later

  //       _openApp(context);
  //     } else {
  //       _showSnackBar(context, 'Facebook login cancelled');
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());

  //     if (!context.mounted) return;
  //     _showSnackBar(context, 'Facebook login failed');
  //   }
  // }

  // void _onAppleLogin(BuildContext context) {
  //   _showSnackBar(context, 'Apple Sign In available on iOS devices.');
  // }

  // void _onPhoneLogin(BuildContext context) {
  //   Navigator.of(
  //     context,
  //   ).push(MaterialPageRoute(builder: (_) => const PhoneLoginScreen()));
  // }

  void _continueAsGuest(BuildContext context) {
    _openApp(context);
  }

  void _openApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNavigation()),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(color: AppColors.background),
            child: SizedBox.expand(),
          ),
          const Positioned(top: 92, left: 0, right: 0, child: _WarmIconGlow()),
          Positioned.fill(child: CustomPaint(painter: _FilmGrainPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 46),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.amber.withValues(alpha: 0.10),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/trailerbaaz_logo.png',
                              width: 104,
                              height: 104,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            'TrailerBaaz',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Trailers. Buzz. First-day energy.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textGrey,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _VibeChip(label: 'Fresh drops'),
                              _VibeChip(label: 'Fan hype'),
                              _VibeChip(label: 'Watchlist ready'),
                            ],
                          ),
                          const SizedBox(height: 42),
                          _LoginActionButton(
                            label: 'Continue with Google',
                            assetPath: 'assets/icons/google_logo.svg',
                            foregroundColor: AppColors.textWhite,
                            backgroundColor: AppColors.chip,
                            borderColor: Colors.white,
                            borderOpacity: 0.12,
                            fontWeight: FontWeight.w600,
                            onTap: () => _onGoogleLogin(context),
                          ),
                          const SizedBox(height: 12),
                          _LoginActionButton(
                            label: 'Browse without signing in',
                            foregroundColor: AppColors.textGrey,
                            backgroundColor: Colors.transparent,
                            borderColor: Colors.white,
                            borderOpacity: 0.06,
                            fontWeight: FontWeight.w500,
                            onTap: () => _continueAsGuest(context),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 32, bottom: 24),
                            child: Text(
                              'By continuing, you agree to our Terms and Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WarmIconGlow extends StatelessWidget {
  const _WarmIconGlow();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.amber.withValues(alpha: 0.06), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginActionButton extends StatefulWidget {
  final String label;
  final String? assetPath;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderOpacity;
  final FontWeight fontWeight;
  final VoidCallback onTap;

  const _LoginActionButton({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderOpacity,
    required this.fontWeight,
    required this.onTap,
    this.assetPath,
  });

  @override
  State<_LoginActionButton> createState() => _LoginActionButtonState();
}

class _LoginActionButtonState extends State<_LoginActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.elasticOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.borderColor.withValues(alpha: widget.borderOpacity)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.assetPath != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(widget.assetPath!, height: 22, width: 22),
                ),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(color: widget.foregroundColor, fontSize: 16, fontWeight: widget.fontWeight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VibeChip extends StatelessWidget {
  final String label;

  const _VibeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFCCCCCC),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FilmGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.018);
    const step = 9.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final seed = (x * 17 + y * 31).round();
        if (seed % 5 == 0) {
          canvas.drawCircle(Offset(x + (seed % 7), y + (seed % 3)), 0.42, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
