import 'package:flutter/material.dart';

import 'auth_button.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onFacebook;
  final VoidCallback onApple;
  final VoidCallback onPhone;

  const SocialLoginButtons({
    super.key,
    required this.onFacebook,
    required this.onApple,
    required this.onPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthButton(
          assetPath: 'assets/icons/apple_logo.svg',
          label: 'Continue with Apple',
          onPressed: onApple,
        ),
        const SizedBox(height: 16),
        AuthButton(
          assetPath: 'assets/icons/facebook_logo.svg',
          label: 'Continue with Facebook',
          onPressed: onFacebook,
        ),
        const SizedBox(height: 16),
        AuthButton(
          icon: Icons.phone_rounded,
          label: 'Continue with Phone Number',
          onPressed: onPhone,
        ),
      ],
    );
  }
}
