import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../navigation/bottom_navigation_screen.dart';
import 'phone_login_screen.dart';
import '../widgets/google_login_button.dart';

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

  Future<void> _onFacebookLogin(BuildContext context) async {
    try {
      final result = await FacebookAuth.instance.login();
      if (!context.mounted) return;

      if (result.status == LoginStatus.success) {
        _showSnackBar(context, 'Facebook login successful');

        // TODO: Send access token to FastAPI later

        _openApp(context);
      } else {
        _showSnackBar(context, 'Facebook login cancelled');
      }
    } catch (e) {
      debugPrint(e.toString());

      if (!context.mounted) return;
      _showSnackBar(context, 'Facebook login failed');
    }
  }

  void _onAppleLogin(BuildContext context) {
    _showSnackBar(context, 'Apple Sign In available on iOS devices.');
  }

  void _onPhoneLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PhoneLoginScreen()));
  }

  void _continueAsGuest(BuildContext context) {
    _openApp(context);
  }

  void _openApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.15,
            colors: [Color(0xFF4B1238), Color(0xFF12162A), Color(0xFF05060A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        const Positioned(top: 34, right: -72, child: _GlowOrb(size: 164, color: Color(0x665A8CFF))),
                        const Positioned(bottom: 108, left: -82, child: _GlowOrb(size: 190, color: Color(0x66FF2E63))),
                        Column(
                          children: [
                            const SizedBox(height: 46),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF2E63).withValues(alpha: 0.22),
                                    blurRadius: 38,
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
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Trailers. Buzz. First-day energy.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.72),
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
                            GoogleLoginButton(
                              onPressed: () => _onGoogleLogin(context),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 32, bottom: 24),
                              child: Text(
                                'By continuing, you agree to our Terms and Privacy Policy.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
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
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
