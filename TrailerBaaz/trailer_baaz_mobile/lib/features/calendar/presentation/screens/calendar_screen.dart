import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_widget.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ComingSoonWidget(
        icon: Icons.calendar_month_rounded,
        title: 'Calendar',
      ),
    );
  }
}
