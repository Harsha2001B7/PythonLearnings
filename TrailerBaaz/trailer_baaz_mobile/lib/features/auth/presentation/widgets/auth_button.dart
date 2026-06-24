import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final String? assetPath;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.assetPath,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final leading = assetPath != null
        ? SvgPicture.asset(assetPath!, height: 22, width: 22)
        : Icon(icon, size: 22, color: Colors.white);
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2E63).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xDD11131F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: leading),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
