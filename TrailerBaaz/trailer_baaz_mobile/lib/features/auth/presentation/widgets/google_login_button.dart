import 'package:flutter/material.dart';

import 'auth_button.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleLoginButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      label: 'Continue with Google',
      onPressed: onPressed,
      assetPath: 'assets/icons/google_logo.svg',
    );
  }
}
