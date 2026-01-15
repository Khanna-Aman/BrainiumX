import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../legal/about_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Name'),
                      subtitle: Text(userProfile?.displayName ?? 'Unknown'),
                    ),
                    if (userProfile?.dob != null)
                      ListTile(
                        leading: const Icon(Icons.cake),
                        title: const Text('Date of Birth'),
                        subtitle: Text(
                          '${userProfile!.dob!.day}/${userProfile.dob!.month}/${userProfile.dob!.year}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      subtitle: Text(_getThemeDisplayName(
                          userProfile?.preferredTheme ?? 'default')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showThemeSelector(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.star),
                      title: const Text('Rating System'),
                      subtitle:
                          const Text('How your cognitive rating is calculated'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push('/rating-help'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.games),
                      title: const Text('How Games Work'),
                      subtitle: const Text(
                          'Detailed guide for all 12 cognitive games'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push('/games-help'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.trending_up),
                      title: const Text('Cognitive Domains'),
                      subtitle:
                          const Text('What each game measures and improves'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push('/domains-help'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.article),
                      title: const Text('About BrainiumX'),
                      subtitle: const Text(
                          'Learn more about our brain training platform'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showAbout(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      subtitle: const Text('How we protect your data'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showPrivacyPolicy(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.gavel),
                      title: const Text('Terms of Service'),
                      subtitle: const Text('Usage terms and conditions'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showTerms(context),
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

  void _showAbout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TermsScreen(),
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System Default';
      case 'default':
        return 'System Default';
      default:
        return 'System Default';
    }
  }

  String _normalizeTheme(String theme) {
    // Convert 'default' to 'system' for consistent comparison
    return theme == 'default' ? 'system' : theme;
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Theme',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              title: 'Light',
              subtitle: 'Always use light theme',
              icon: Icons.light_mode,
              value: 'light',
              currentTheme: _normalizeTheme(
                  ref.watch(userProfileProvider)?.preferredTheme ?? 'default'),
              onTap: () => _updateTheme(context, ref, 'light'),
            ),
            _ThemeOption(
              title: 'Dark',
              subtitle: 'Always use dark theme',
              icon: Icons.dark_mode,
              value: 'dark',
              currentTheme: _normalizeTheme(
                  ref.watch(userProfileProvider)?.preferredTheme ?? 'default'),
              onTap: () => _updateTheme(context, ref, 'dark'),
            ),
            _ThemeOption(
              title: 'System Default',
              subtitle: 'Follow system theme setting',
              icon: Icons.settings_brightness,
              value: 'system',
              currentTheme: _normalizeTheme(
                  ref.watch(userProfileProvider)?.preferredTheme ?? 'default'),
              onTap: () => _updateTheme(context, ref, 'system'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _updateTheme(BuildContext context, WidgetRef ref, String theme) async {
    await ref.read(userProfileProvider.notifier).updateTheme(theme);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String currentTheme;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.currentTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTheme == value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
