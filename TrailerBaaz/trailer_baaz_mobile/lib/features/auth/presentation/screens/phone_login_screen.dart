import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../navigation/bottom_navigation_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? _verificationId;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) return _showSnackBar('Enter a valid 10-digit phone number.');
    setState(() => _sendingOtp = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        if (!mounted) return;
        _openApp();
      },
      verificationFailed: (e) {
        if (!mounted) return;
        setState(() => _sendingOtp = false);
        _showSnackBar(e.message ?? 'Failed to send OTP.');
      },
      codeSent: (verificationId, _) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _sendingOtp = false;
        });
        _showSnackBar('OTP sent successfully.');
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if ((_verificationId ?? '').isEmpty || otp.length != 6) {
      return _showSnackBar('Enter the 6-digit OTP.');
    }
    setState(() => _verifyingOtp = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      if (!mounted) return;
      _openApp();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message ?? 'OTP verification failed.');
    } finally {
      if (mounted) setState(() => _verifyingOtp = false);
    }
  }

  void _openApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNavigation()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Number')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+91 ',
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _sendingOtp ? null : _sendOtp,
                child: Text(_sendingOtp ? 'Sending OTP...' : 'Send OTP'),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP',
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _verifyingOtp ? null : _verifyOtp,
                child: Text(_verifyingOtp ? 'Verifying...' : 'Verify OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
