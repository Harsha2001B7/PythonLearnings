import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class TicketPanel extends StatelessWidget {
  const TicketPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF241719), Color(0xFF171420)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tickets Available Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Book tickets from your preferred partner.',
            style: TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.confirmation_number_rounded,
                      size: 17),
                  label:
                      const FittedBox(child: Text('BookMyShow')),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF416D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_activity_rounded, size: 17),
                  label: const FittedBox(child: Text('District')),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF241F31),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: .12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
