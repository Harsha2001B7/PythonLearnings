import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_theme.dart';

// ─── Popcorn Rating Options ───────────────────────────────────────────────────

class PopcornOption {
  const PopcornOption({required this.label, required this.value});
  final String label;
  final int value; // 1–5
}

const _popcornOptions = [
  PopcornOption(label: 'Hard pass', value: 1),
  PopcornOption(label: 'One kernel?', value: 2),
  PopcornOption(label: 'Pop me', value: 3),
  PopcornOption(label: 'Gift popcorn', value: 4),
  PopcornOption(label: 'Feed the\nbucket', value: 5),
];

// ─── Show helper ─────────────────────────────────────────────────────────────

Future<void> showPopcornRating(
  BuildContext context, {
  required int hypeScore,
  required int? currentRating,
  required ValueChanged<int?> onRatingChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PopcornRatingSheet(
      hypeScore: hypeScore,
      initialRating: currentRating,
      onRatingChanged: onRatingChanged,
    ),
  );
}

// ─── Sheet Widget ─────────────────────────────────────────────────────────────

class _PopcornRatingSheet extends StatefulWidget {
  const _PopcornRatingSheet({
    required this.hypeScore,
    required this.initialRating,
    required this.onRatingChanged,
  });

  final int hypeScore;
  final int? initialRating;
  final ValueChanged<int?> onRatingChanged;

  @override
  State<_PopcornRatingSheet> createState() => _PopcornRatingSheetState();
}

class _PopcornRatingSheetState extends State<_PopcornRatingSheet> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialRating;
  }

  void _pick(int value) {
    HapticFeedback.mediumImpact();
    final next = _selected == value ? null : value;
    setState(() => _selected = next);
    widget.onRatingChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final option = _selected != null
        ? _popcornOptions.firstWhere((o) => o.value == _selected)
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Audience hype bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Audience hype',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.hypeScore}/100',
                      style: const TextStyle(
                        color: AppTheme.hype,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: widget.hypeScore / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.hype),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Popcorn level title
          const Text(
            '🍿  Your popcorn level',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            _selected != null
                ? '$_selected of 5 pops · one rating per trailer'
                : '0 of 5 pops · one rating per trailer',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),

          const SizedBox(height: 20),

          // Rating buttons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _popcornOptions.map((opt) {
                final isSelected = _selected == opt.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _pick(opt.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.hype.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.hype
                              : Colors.white.withValues(alpha: 0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🍿', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 6),
                          Text(
                            opt.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.hype
                                  : Colors.white70,
                              fontSize: 9,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Status line
          if (option != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: AppTheme.hype,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(text: 'Your pop: ${option.label} '),
                    const TextSpan(
                      text: '— tap to change',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Tap a level to rate this trailer',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Compact Popcorn Badge (replaces HypeLabel) ───────────────────────────────

class PopcornBadge extends StatelessWidget {
  const PopcornBadge({
    super.key,
    required this.score,
    required this.onTap,
    this.compact = false,
  });

  final int score;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🍿', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 3),
          Text(
            '$score%',
            style: TextStyle(
              color: compact ? AppTheme.hype : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 12 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
