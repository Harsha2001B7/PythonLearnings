import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../../../shared/widgets/glass_surfaces.dart';

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
        Text(
          trailer.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 26,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaPill(label: trailer.industry),
            _MetaPill(label: trailer.language),
            _MetaPill(label: trailer.genre),
            _MetaPill(label: trailer.releaseYear),
            _MetaPill(label: trailer.runtime),
            _MetaPill(label: trailer.rating),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          trailer.overview,
          maxLines: _expanded ? null : 4,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textGrey,
            height: 1.5,
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          style: TextButton.styleFrom(foregroundColor: AppColors.amber),
          child: Text(
            _expanded ? 'Show Less' : 'Read More',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
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
    return GlassSurface(
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      backgroundOpacity: 0.08,
      borderOpacity: 0.10,
      boxShadow: const [],
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
