import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';

class InfoSection extends StatefulWidget {
  final TrailerModel trailer;

  const InfoSection({super.key, required this.trailer});

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final trailer = widget.trailer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(trailer.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetaPill(label: trailer.industry),
            _MetaPill(label: trailer.language),
            _MetaPill(label: trailer.genre),
            _MetaPill(label: trailer.releaseYear),
            _MetaPill(label: trailer.runtime),
            _MetaPill(label: trailer.rating),
          ],
        ),
        const SizedBox(height: 20),
        Text('Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(
          trailer.overview,
          maxLines: _expanded ? null : 4,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textGrey, height: 1.5),
        ),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? 'Show Less' : 'Read More'),
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
