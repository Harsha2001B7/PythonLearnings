import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../../core/widgets/toast_notification.dart';
import '../../../../core/repositories/fleet_repository.dart';
import '../../../../core/models/faq.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  bool _pushNotifications = true;
  String _billingMode = 'monthly';
  String _faqSearch = '';
  String _activeFaqCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Account & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── PROFILE HERO CARD ──
            _buildProfileHero(),
            const SizedBox(height: 20),

            // ── PRIVILEGES & MEMBERSHIP ──
            _buildSettingGroup(
              title: 'PRIVILEGES',
              children: [
                _buildSettingTile(
                  icon: Icons.star_outline_rounded,
                  title: 'SAFRA Membership Perks',
                  subtitle: 'Scout · Vantage · Apex',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showMembershipBottomSheet(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── SUPPORT & DOCUMENTATION ──
            _buildSettingGroup(
              title: 'SUPPORT',
              children: [
                _buildSettingTile(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQ Accordion',
                  subtitle: 'Booking, insurance, delivery...',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showFaqBottomSheet(context);
                  },
                ),
                _buildSettingTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Rental agreements & rules',
                  onTap: () {
                    ToastNotification.show(context, 'Terms and agreements documentation loaded.', type: 'info');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── PREFERENCES ──
            _buildSettingGroup(
              title: 'PREFERENCES',
              children: [
                SwitchListTile(
                  activeThumbColor: AppColors.amber,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.amber, size: 20),
                  title: Text('Push Notifications', style: AppTypography.headingSmall()),
                  subtitle: Text('Receive booking confirmations & updates', style: AppTypography.bodySmall()),
                  value: _pushNotifications,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _pushNotifications = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Sign out button
            CustomButton.ghost(
              text: 'Sign Out',
              width: double.infinity,
              onPressed: () {
                HapticFeedback.mediumImpact();
                ToastNotification.show(context, 'Signed out of SAFRA.', type: 'info');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHero() {
    return ShimmerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.amber,
              child: Text(
                'JD',
                style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Doe', style: AppTypography.headingLarge()),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'VIP APEX MEMBER',
                          style: AppTypography.monoBold(color: AppColors.amber, size: 7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
          child: Text(title, style: AppTypography.eyebrow()),
        ),
        ShimmerCard(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.amber, size: 20),
      title: Text(title, style: AppTypography.headingSmall()),
      subtitle: Text(subtitle, style: AppTypography.bodySmall()),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.inkSubtle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // ── MEMBERSHIP DETAIL BOTTOM SHEET ──
  void _showMembershipBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final tiers = FleetRepository.membershipTiers;

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: const EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SAFRA PRIVILEGES', style: AppTypography.eyebrow()),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Billing Toggle
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.paperSoft,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setSheetState(() => _billingMode = 'monthly');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: _billingMode == 'monthly' ? AppColors.amber : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Monthly',
                                style: AppTypography.monoStyle(
                                  color: _billingMode == 'monthly' ? Colors.white : AppColors.inkMuted,
                                  size: 8.0,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setSheetState(() => _billingMode = 'annual');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: _billingMode == 'annual' ? AppColors.amber : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Annual (Save 17%)',
                                style: AppTypography.monoStyle(
                                  color: _billingMode == 'annual' ? Colors.white : AppColors.inkMuted,
                                  size: 8.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tiers List
                  Expanded(
                    child: ListView(
                      children: tiers.map((tier) {
                        final double price = _billingMode == 'annual' && tier.pricePerYear != null
                            ? (tier.pricePerYear! / 12).roundToDouble()
                            : tier.pricePerMonth;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ShimmerCard(
                            borderHighlight: tier.highlighted,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        tier.name,
                                        style: AppTypography.headingLarge(
                                          color: tier.highlighted ? AppColors.amber : AppColors.ink,
                                        ),
                                      ),
                                      if (tier.badge != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: tier.highlighted ? AppColors.amber : AppColors.paperSoft,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            tier.badge!,
                                            style: AppTypography.monoStyle(
                                              color: tier.highlighted ? Colors.white : AppColors.inkMuted,
                                              size: 7,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(tier.tagline, style: AppTypography.bodySmall()),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        price == 0 ? 'Free' : 'AED ${price.toInt()}',
                                        style: AppTypography.headingLarge(color: AppColors.ink).copyWith(fontSize: 26),
                                      ),
                                      if (price > 0)
                                        Text(
                                          '/month',
                                          style: AppTypography.bodySmall(),
                                        ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  ...tier.features.take(3).map((feat) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              feat.included ? Icons.check_circle : Icons.cancel,
                                              color: feat.included ? AppColors.amber : AppColors.inkSubtle,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                feat.text,
                                                style: AppTypography.bodyMedium(
                                                  color: feat.included ? AppColors.ink : AppColors.inkSubtle,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 12),
                                  CustomButton.amber(
                                    text: tier.ctaLabel,
                                    width: double.infinity,
                                    height: 32.0,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      Navigator.pop(context);
                                      ToastNotification.show(context, 'Subscribed to ${tier.name}!', type: 'success');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── FAQ DETAIL BOTTOM SHEET ──
  void _showFaqBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setFaqState) {
            final List<FAQItem> faqs = FleetRepository.faqData.where((faq) {
              final matchesCategory = _activeFaqCategory == 'all' || faq.category == _activeFaqCategory;
              final matchesSearch = faq.question.toLowerCase().contains(_faqSearch.toLowerCase()) ||
                  faq.answer.toLowerCase().contains(_faqSearch.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: const EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SUPPORT QUESTIONS', style: AppTypography.eyebrow()),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Search box
                  TextField(
                    onChanged: (val) {
                      setFaqState(() {
                        _faqSearch = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search FAQs...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      fillColor: AppColors.paper,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Categories Chips row
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['all', 'booking', 'insurance', 'delivery', 'pricing', 'membership'].map((cat) {
                        final active = _activeFaqCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setFaqState(() {
                                _activeFaqCategory = cat;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: active ? AppColors.amber : AppColors.paperSoft,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Text(
                                  cat.toUpperCase(),
                                  style: AppTypography.monoStyle(
                                    color: active ? Colors.white : AppColors.inkMuted,
                                    size: 7.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Expandable list
                  Expanded(
                    child: faqs.isEmpty
                        ? Center(child: Text('No matching FAQ items.', style: AppTypography.bodyMedium()))
                        : ListView.builder(
                            itemCount: faqs.length,
                            itemBuilder: (context, index) {
                              final faq = faqs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.paper,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ExpansionTile(
                                    shape: const Border(),
                                    iconColor: AppColors.amber,
                                    collapsedIconColor: AppColors.inkMuted,
                                    title: Text(
                                      faq.question,
                                      style: AppTypography.headingSmall(),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                                        child: Text(
                                          faq.answer,
                                          style: AppTypography.bodyMedium(color: AppColors.inkMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
