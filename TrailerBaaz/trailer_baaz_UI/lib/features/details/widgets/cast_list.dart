import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/trailer.dart';
import '../../../shared/widgets/cinematic_image.dart';

class CastList extends StatelessWidget {
  const CastList({super.key, required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cast.length,
        separatorBuilder: (_, _) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final member = cast[index];
          return SizedBox(
            width: 72,
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CinematicImage(url: member.imageUrl),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  member.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 10, color: AppTheme.muted),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
