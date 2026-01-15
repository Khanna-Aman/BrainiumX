import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Terms of Service',
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
                'Terms of Service',
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
                'Agreement to Terms',
                'By downloading, installing, or using BrainiumX, you agree to be bound by these Terms of Service. If you do not agree to these Terms, please do not use the App.',
              ),

              // Description of Service
              _buildSection(
                context,
                'Description of Service',
                'BrainiumX is a brain training application designed to enhance various aspects of cognitive function through engaging games and exercises. The App provides:',
              ),

              _buildBulletPoint(context, 'Brain training games and exercises'),
              _buildBulletPoint(context, 'Performance tracking and analytics'),
              _buildBulletPoint(context, 'Adaptive difficulty adjustment'),
              _buildBulletPoint(context, 'Achievement and progress systems'),
              _buildBulletPoint(context, 'Data export and backup features'),

              // User Responsibilities
              _buildSection(
                context,
                'User Responsibilities',
                'As a user of BrainiumX, you agree to:',
              ),

              _buildBulletPoint(context,
                  'Use the App for its intended purpose of brain training'),
              _buildBulletPoint(context,
                  'Provide accurate information when creating your profile'),
              _buildBulletPoint(
                  context, 'Not attempt to reverse engineer or modify the App'),
              _buildBulletPoint(context,
                  'Not use the App for any illegal or unauthorized purpose'),
              _buildBulletPoint(context,
                  'Respect the intellectual property rights of the App'),

              // Medical Disclaimer
              _buildHighlightBox(
                context,
                'Important Medical Disclaimer',
                'BrainiumX is designed for cognitive enhancement and entertainment purposes only. It is not intended to diagnose, treat, cure, or prevent any medical condition. Always consult with healthcare professionals for medical advice.',
                Icons.medical_services,
                Colors.orange,
              ),

              // Intellectual Property
              _buildSection(
                context,
                'Intellectual Property Rights',
                'BrainiumX and all its content, features, and functionality are owned by Aman Khanna and are protected by international copyright, trademark, and other intellectual property laws.',
              ),

              // Privacy and Data
              _buildSection(
                context,
                'Privacy and Data Protection',
                'Your privacy is important to us. Our data practices are governed by our Privacy Policy, which is incorporated into these Terms by reference. Key points:',
              ),

              _buildBulletPoint(
                  context, 'All data is stored locally on your device'),
              _buildBulletPoint(context,
                  'No personal data is transmitted to external servers'),
              _buildBulletPoint(
                  context, 'You maintain complete control over your data'),
              _buildBulletPoint(
                  context, 'Data can be exported or deleted at any time'),

              // Limitation of Liability
              _buildSection(
                context,
                'Limitation of Liability',
                'To the maximum extent permitted by law, Aman Khanna shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the App.',
              ),

              // Disclaimers
              _buildSection(
                context,
                'Disclaimers',
                'The App is provided "as is" and "as available" without warranties of any kind. We do not guarantee that the App will be error-free or uninterrupted.',
              ),

              // Age Requirements
              _buildSection(
                context,
                'Age Requirements',
                'BrainiumX is suitable for users of all ages. However, users under 13 should have parental supervision and consent before using the App.',
              ),

              // Updates and Modifications
              _buildSection(
                context,
                'Updates and Modifications',
                'We reserve the right to modify these Terms at any time. Changes will be effective immediately upon posting within the App. Continued use constitutes acceptance of modified Terms.',
              ),

              // Termination
              _buildSection(
                context,
                'Termination',
                'You may stop using the App at any time. We may terminate or suspend access to the App immediately, without prior notice, for conduct that we believe violates these Terms.',
              ),

              // Governing Law
              _buildSection(
                context,
                'Governing Law',
                'These Terms shall be governed by and construed in accordance with applicable laws, without regard to conflict of law principles.',
              ),

              const SizedBox(height: 32),

              // Acceptance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acceptance of Terms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By using BrainiumX, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ],
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
