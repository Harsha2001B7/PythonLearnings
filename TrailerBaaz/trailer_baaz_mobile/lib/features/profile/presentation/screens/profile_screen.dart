import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ComingSoonWidget(
        icon: Icons.person_rounded,
        title: 'Profile',
      ),
    );
  }
}
