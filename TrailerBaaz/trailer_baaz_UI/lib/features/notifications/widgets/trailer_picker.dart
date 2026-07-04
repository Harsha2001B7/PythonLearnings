import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/trailer.dart';

class TrailerPicker extends StatelessWidget {
  const TrailerPicker({
    super.key,
    required this.trailers,
    required this.selectedTrailerId,
    required this.onChanged,
  });

  final List<Trailer> trailers;
  final String selectedTrailerId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trailer', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedTrailerId,
              dropdownColor: AppTheme.card,
              isExpanded: true,
              items: trailers.map((trailer) {
                return DropdownMenuItem(
                  value: trailer.id,
                  child: Text(trailer.title, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
