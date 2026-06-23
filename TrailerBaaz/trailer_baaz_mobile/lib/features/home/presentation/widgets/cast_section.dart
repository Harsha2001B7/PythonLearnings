import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CastSection extends StatelessWidget {
  final List<String> castMembers;

  const CastSection({super.key, required this.castMembers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cast', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: castMembers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _CastCard(name: castMembers[index]),
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final String name;

  const _CastCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 26, backgroundColor: Colors.white10, child: Icon(Icons.person_rounded)),
          const SizedBox(height: 10),
          Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
