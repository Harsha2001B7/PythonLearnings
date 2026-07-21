import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../data/models/user_model.dart';
import '../controllers/auth_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Google Web Client ID
//
// This is the OAuth 2.0 Web Client ID from the Google Cloud Console.
// It is used as `serverClientId` so that google_sign_in on Android requests
// an ID Token issued to this audience.
//
// The backend validates: id_info["aud"] == settings.GOOGLE_CLIENT_ID
// Both this value and the backend .env GOOGLE_CLIENT_ID must match.
// ─────────────────────────────────────────────────────────────────────────────
const _kGoogleWebClientId =
    '291772363929-25to6jat1j1puo3kmghrlf3aue5b3qvh.apps.googleusercontent.com';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ─── Google Sign-In client ────────────────────────────────────────────────
  // `serverClientId` tells google_sign_in which audience the ID Token should
  // be issued to. The backend verifies this matches GOOGLE_CLIENT_ID in .env.
  // No google-services.json or Firebase dependency is required.
  final _googleSignIn = GoogleSignIn(
    serverClientId: _kGoogleWebClientId,
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ─── Navigate after login based on role ───────────────────────────────────
  // Mirrors the React flow:
  //   profileResponse.data.role_id === 1 → '/admin'
  //   else                               → '/'
  void _navigateForRole(UserModel user) {
    if (user.isAdmin) {
      context.go(AppRoute.adminHome);
    } else {
      context.go(AppRoute.home);
    }
  }

  // ─── Email / password login ───────────────────────────────────────────────
  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (!mounted) return;
      final authState = ref.read(authControllerProvider);
      if (authState is AuthAuthenticated) {
        _navigateForRole(authState.user);
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e, stackTrace) {
      debugPrint('====================================================');
      debugPrint('EMAIL LOGIN ERROR DETAILS:');
      debugPrint('Exception: $e');
      debugPrint('Stack trace:\n$stackTrace');
      debugPrint('====================================================');
      if (mounted) _showError('Invalid email or credentials.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  // Flow (identical to React handleGoogleCredential):
  //   1. google_sign_in → native Google account picker
  //   2. account.authentication.idToken  (issued for _kGoogleWebClientId)
  //   3. POST /auth/google { id_token }  → access_token + refresh_token
  //   4. GET  /auth/me                   → UserModel (via AuthRepository)
  //   5. Persist tokens in flutter_secure_storage
  //   6. Navigate: role_id==1 → /admin, else → /
  Future<void> _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // Force sign out first to clear any cached credentials and guarantee a fresh ID token
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('Google Sign-Out pre-clear ignored: $e');
      }

      // Step 1: Native Google account picker — returns null if user cancels
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the picker — not an error
        setState(() => _isLoading = false);
        return;
      }

      // Step 2: Get the ID Token from the selected account
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw AuthException(
          'Google did not return an ID Token. '
          'Ensure the Web Client ID is configured correctly in the Google Cloud Console.',
        );
      }

      // Steps 3-5: Delegate to AuthController → AuthRepository → backend
      await ref.read(authControllerProvider.notifier).loginWithGoogle(idToken);

      if (!mounted) return;

      // Step 6: Role-based navigation
      final authState = ref.read(authControllerProvider);
      if (authState is AuthAuthenticated) {
        _navigateForRole(authState.user);
      }
    } on AuthException catch (e) {
      debugPrint('====================================================');
      debugPrint('GOOGLE SIGN-IN AUTH EXCEPTION:');
      debugPrint('Message: ${e.message}');
      debugPrint('====================================================');
      if (mounted) _showError(e.message);
    } catch (e, stackTrace) {
      debugPrint('====================================================');
      debugPrint('GOOGLE SIGN-IN FAILURE DETAILS:');
      debugPrint('Exception type/message: $e');
      debugPrint('Stack trace:\n$stackTrace');
      
      // If the exception has response info (e.g. DioException from calling the backend)
      final rawStr = e.toString();
      String backendResp = 'N/A';
      String httpStatus = 'N/A';
      
      if (rawStr.contains('DioException') || rawStr.contains('response')) {
        // We can check if it has response details
        // To avoid compilation errors if e is not DioException, we check dynamically or catch
        try {
          dynamic dynamicError = e;
          if (dynamicError.response != null) {
            backendResp = '${dynamicError.response.data}';
            httpStatus = '${dynamicError.response.statusCode}';
          }
        } catch (_) {}
      }
      
      debugPrint('Google Sign-In error: $e');
      debugPrint('Backend response: $backendResp');
      debugPrint('HTTP status code: $httpStatus');
      debugPrint('Exception message: $rawStr');
      debugPrint('====================================================');

      // Surface a user-friendly error message that matches the failure
      String msg;
      if (rawStr.contains('Audience mismatch') || rawStr.contains('aud')) {
        msg = 'Google Sign-In configuration error (Audience mismatch). Contact support.';
      } else if (rawStr.contains('Invalid Google ID token')) {
        msg = 'Google authentication failed (Invalid ID token). Please try again.';
      } else if (rawStr.contains('SocketException') || rawStr.contains('connection')) {
        msg = 'Cannot reach server. Check your internet connection.';
      } else if (rawStr.contains('10')) {
        msg = 'Google Sign-In Error 10: Typically indicates SHA-1 mismatch or wrong client ID config in Google Developer Console.';
      } else {
        msg = 'Google Sign-In failed: $rawStr';
      }
      if (mounted) _showError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textSecColor = isDark ? AppColors.textSecDark : AppColors.textSecLight;
    final textMutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderMidDark : AppColors.borderMidLight;
    final inputBg = isDark ? AppColors.surface2Dark : AppColors.surface2Light;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ─── Ambient glow orbs ───────────────────────────────────────────
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.1,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.sizeOf(context).height * 0.1,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withValues(alpha: 0.04),
              ),
            ),
          ),

          // ─── Theme toggle (top-right) ────────────────────────────────────
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: const ThemeToggleButton(),
          ),

          // ─── Scrollable content ──────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // ─── Brand header ──────────────────────────────────
                      SizedBox(
                        width: 88,
                        height: 88,
                        child: Image.asset(
                          'lib/assets/falconviewLogotransparentbackground.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to access your luxury experience',
                        style: TextStyle(
                          color: textMutedColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Form ──────────────────────────────────────────
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email field
                            _fieldLabel('EMAIL ADDRESS', textSecColor),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: textColor, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'you@example.com',
                                prefixIcon: Icon(Icons.alternate_email_rounded,
                                    size: 18, color: textMutedColor),
                                filled: true,
                                fillColor: inputBg,
                                border: _inputBorder(borderColor),
                                enabledBorder: _inputBorder(borderColor),
                                focusedBorder:
                                    _inputBorder(AppColors.orange, width: 1.5),
                                errorBorder: _inputBorder(AppColors.error),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!v.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _fieldLabel('PASSWORD', textSecColor),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onLogin(),
                              style: TextStyle(color: textColor, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_outline_rounded,
                                    size: 18, color: textMutedColor),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                    color: textMutedColor,
                                  ),
                                ),
                                filled: true,
                                fillColor: inputBg,
                                border: _inputBorder(borderColor),
                                enabledBorder: _inputBorder(borderColor),
                                focusedBorder:
                                    _inputBorder(AppColors.orange, width: 1.5),
                                errorBorder: _inputBorder(AppColors.error),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                if (v.length < 6) {
                                  return 'Minimum 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // ─── Sign In button ────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppColors.orange.withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── Divider ─────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                              child: Divider(color: borderColor, thickness: 1)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: textMutedColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: borderColor, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _onGoogleSignIn,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'lib/assets/google.svg',
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── Register link ────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoute.register),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: textMutedColor,
                                  fontSize: 13,
                                ),
                                children: const [
                                  TextSpan(text: 'New to Falcon View? '),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, Color color) => Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
}

// ─── AuthException ────────────────────────────────────────────────────────────
/// Typed exception carrying a user-readable message from backend or local logic.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}


