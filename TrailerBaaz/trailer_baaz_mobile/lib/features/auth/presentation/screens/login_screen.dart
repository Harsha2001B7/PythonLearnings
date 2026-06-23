import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../navigation/bottom_navigation_screen.dart';
import 'phone_login_screen.dart';
import '../widgets/google_login_button.dart';
import '../widgets/social_login_buttons.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 52),
                      Image.asset(
                        'assets/images/trailerbaaz_logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'TrailerBaaz',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stream trailers, discover buzz, and never miss a release.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      GoogleLoginButton(
                        onPressed: () => _onGoogleLogin(context),
                      ),
                      const SizedBox(height: 16),
                      SocialLoginButtons(
                        onFacebook: () => _onFacebookLogin(context),
                        onApple: () => _onAppleLogin(context),
                        onPhone: () => _onPhoneLogin(context),
                      ),
                      const SizedBox(height: 28),
                      TextButton(
                        onPressed: () => _continueAsGuest(context),
                        child: const Text('Continue as Guest'),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 24),
                        child: Text(
                          'By continuing, you agree to our Terms and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
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
    );
  }
}
