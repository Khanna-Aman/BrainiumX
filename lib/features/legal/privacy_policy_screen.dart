import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Privacy Policy',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: January 2025',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 32),

              // Introduction
              _buildSection(
                context,
                'Introduction',
                'BrainiumX is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our brain training game application.',
              ),

              // Information We Collect
              _buildSection(
                context,
                'Information We Collect',
                'BrainiumX operates on a privacy-first principle. All data collection is limited to what is necessary for app functionality:',
              ),

              _buildSubSection(
                context,
                'Personal Information',
                '• Display name\n• App preferences and settings',
              ),

              _buildSubSection(
                context,
                'Usage Data',
                '• Game performance scores and accuracy\n• Reaction times and response patterns\n• Training session duration and frequency\n• Achievement progress and streaks',
              ),

              _buildSubSection(
                context,
                'Technical Data',
                '• App version and device information\n• Error logs and crash reports (anonymous)\n• Performance metrics for app optimization',
              ),

              // How We Use Information
              _buildSection(
                context,
                'How We Use Your Information',
                'Your information is used exclusively to enhance your cognitive training experience:',
              ),

              _buildBulletPoint(context,
                  'Personalize difficulty levels and game recommendations'),
              _buildBulletPoint(context,
                  'Track your progress and provide meaningful analytics'),
              _buildBulletPoint(
                  context, 'Maintain achievement records and training streaks'),
              _buildBulletPoint(
                  context, 'Improve app performance and fix technical issues'),
              _buildBulletPoint(
                  context, 'Provide customer support when requested'),

              // Data Storage and Security
              _buildSection(
                context,
                'Data Storage and Security',
                'Your privacy and data security are our top priorities:',
              ),

              _buildHighlightBox(
                context,
                'Local Storage Only',
                'All your personal data and game records are stored exclusively on your device using encrypted local storage. We do not transmit, store, or access your data on external servers.',
                Icons.security,
                Colors.green,
              ),

              _buildSubSection(
                context,
                'Security Measures',
                '• End-to-end encryption for all stored data\n• No network transmission of personal information\n• Secure local database with access controls\n• Regular security audits and updates',
              ),

              // Data Sharing
              _buildSection(
                context,
                'Data Sharing',
                'We do not share, sell, or distribute your personal information to third parties. Your game data remains private and under your complete control.',
              ),

              _buildHighlightBox(
                context,
                'Zero Data Sharing',
                'BrainiumX operates with a strict no-sharing policy. Your data never leaves your device unless you explicitly choose to export it.',
                Icons.block,
                Colors.red,
              ),

              // Your Rights and Controls
              _buildSection(
                context,
                'Your Rights and Controls',
                'You have complete control over your data:',
              ),

              _buildBulletPoint(context,
                  'Access: View all your stored data through the app interface'),
              _buildBulletPoint(
                  context, 'Export: Download your complete game history'),
              _buildBulletPoint(
                  context, 'Delete: Remove all data with a single action'),
              _buildBulletPoint(context,
                  'Modify: Update or correct any personal information'),
              _buildBulletPoint(
                  context, 'Opt-out: Disable any data collection features'),

              // Children's Privacy
              _buildSection(
                context,
                'Children\'s Privacy',
                'BrainiumX is designed to be safe for users of all ages. We do not knowingly collect personal information from children under 13 without parental consent. If you believe a child has provided personal information, please contact us immediately.',
              ),

              // Changes to Privacy Policy
              _buildSection(
                context,
                'Changes to This Privacy Policy',
                'We may update this Privacy Policy periodically. Any changes will be reflected in the app with an updated "Last modified" date. Continued use of the app after changes constitutes acceptance of the updated policy.',
              ),

              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  'Your privacy matters to us.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildSubSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
