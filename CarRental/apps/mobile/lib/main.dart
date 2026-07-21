import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FcmService.instance.initialize().catchError((e) {
      debugPrint('FCM init error: $e');
    });
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    const ProviderScope(
      child: FalconViewApp(),
    ),
  );
}
