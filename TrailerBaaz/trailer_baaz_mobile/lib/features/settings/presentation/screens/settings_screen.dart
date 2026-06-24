import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoplayPreviews = true;
  bool _hdOnWifi = true;
  bool _dataSaver = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _HeaderCard(
                  onLogin: () {},
                  onManage: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _SettingsCard(
                  title: 'PREFERENCES',
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Release reminders and trailer alerts',
                      trailing: Switch(
                        value: _notifications,
                        onChanged: (value) => setState(() => _notifications = value),
                        activeThumbColor: AppColors.amber,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.play_circle_outline_rounded,
                      title: 'Autoplay previews',
                      subtitle: 'Hero and feed previews',
                      trailing: Switch(
                        value: _autoplayPreviews,
                        onChanged: (value) => setState(() => _autoplayPreviews = value),
                        activeThumbColor: AppColors.amber,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.wifi_rounded,
                      title: 'HD on Wi-Fi',
                      subtitle: 'Prefer higher quality posters',
                      trailing: Switch(
                        value: _hdOnWifi,
                        onChanged: (value) => setState(() => _hdOnWifi = value),
                        activeThumbColor: AppColors.amber,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.data_usage_rounded,
                      title: 'Data saver',
                      subtitle: 'Reduce image and video bandwidth',
                      trailing: Switch(
                        value: _dataSaver,
                        onChanged: (value) => setState(() => _dataSaver = value),
                        activeThumbColor: AppColors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _SettingsCard(
                  title: 'APP',
                  children: const [
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'English',
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                    ),
                    _SettingsTile(
                      icon: Icons.movie_filter_outlined,
                      title: 'Preferred industries',
                      subtitle: 'HW, BW, TE, TM',
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                    ),
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy',
                      subtitle: 'Manage account and watch history',
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverToBoxAdapter(
                child: _SettingsCard(
                  title: 'ABOUT',
                  children: const [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'TrailerBaaz',
                      subtitle: 'Version 1.0.0',
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                    ),
                    _SettingsTile(
                      icon: Icons.policy_outlined,
                      title: 'Terms & privacy',
                      subtitle: 'View app policies',
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onManage;

  const _HeaderCard({
    required this.onLogin,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/images/trailerbaaz_logo.png'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tune your TrailerBaaz experience.',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Sign in',
                  filled: true,
                  onTap: onLogin,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Manage',
                  onTap: onManage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.textWhite, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: filled ? AppColors.amber : Colors.white.withValues(alpha: 0.10),
        foregroundColor: filled ? AppColors.background : AppColors.textWhite,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
