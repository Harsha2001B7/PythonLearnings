import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_models.dart';

final faqsProvider = FutureProvider.autoDispose<List<FaqModel>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.fetchFaqs();
});

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqsAsync = ref.watch(faqsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & FAQs',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: faqsAsync.when(
        data: (faqs) {
          if (faqs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.help_outline_rounded, size: 48, color: textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No FAQs available right now.',
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please contact our support for immediate help.',
                      style: TextStyle(color: textMuted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: faqs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      faq.question,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    iconColor: AppColors.orange,
                    collapsedIconColor: textMuted,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.topLeft,
                    children: [
                      Text(
                        faq.answer,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
        error: (err, stack) => Center(
          child: Text('Failed to load FAQs: $err', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}
