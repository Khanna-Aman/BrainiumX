import 'package:flutter/material.dart';

class ScoringHelpScreen extends StatelessWidget {
  const ScoringHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoring System'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewSection(context),
              const SizedBox(height: 24),
              _buildBestScoreSection(context),
              const SizedBox(height: 24),
              _buildRatingSection(context),
              const SizedBox(height: 24),
              _buildGameSpecificSection(context),
              const SizedBox(height: 24),
              _buildCompetitiveSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'How Scoring Works',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'BrainiumX uses two main metrics to track your cognitive performance:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(context, 'Best Score',
                'Your highest score achieved in each game'),
            _buildBulletPoint(context, 'Rating',
                'Your current skill level (like chess ELO rating)'),
          ],
        ),
      ),
    );
  }

  Widget _buildBestScoreSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  'Best Score Explained',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your "Best" score represents the highest score you\'ve ever achieved in that specific game.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(context, 'Updates Automatically',
                'When you beat your previous best, it updates immediately'),
            _buildBulletPoint(context, 'Game-Specific',
                'Each game has its own best score tracking'),
            _buildBulletPoint(context, 'Permanent Record',
                'Your best scores are saved permanently'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: For Speed Tap, "Best" shows your fastest reaction time in milliseconds!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rating System',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your rating is like a chess ELO rating - it measures your current skill level and adjusts based on your performance.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(context, 'Starts at 1200',
                'Everyone begins with a rating of 1200'),
            _buildBulletPoint(context, 'Goes Up/Down',
                'Good performance increases it, poor performance decreases it'),
            _buildBulletPoint(context, 'Adaptive Difficulty',
                'Games get harder as your rating increases'),
            _buildBulletPoint(context, 'Range: 800-2200',
                'Ratings are capped between these values'),
            const SizedBox(height: 12),
            _buildRatingScale(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingScale(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Scale:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildRatingLevel(context, '800-1000', 'Beginner', Colors.grey),
          _buildRatingLevel(context, '1000-1200', 'Novice', Colors.brown),
          _buildRatingLevel(context, '1200-1400', 'Intermediate', Colors.blue),
          _buildRatingLevel(context, '1400-1600', 'Advanced', Colors.purple),
          _buildRatingLevel(context, '1600-1800', 'Expert', Colors.orange),
          _buildRatingLevel(context, '1800-2000', 'Master', Colors.red),
          _buildRatingLevel(context, '2000+', 'Grandmaster', Colors.amber),
        ],
      ),
    );
  }

  Widget _buildRatingLevel(
      BuildContext context, String range, String level, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$range: $level', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildGameSpecificSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.games,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Point Calculation Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Here\'s exactly how points are calculated for each game:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _buildDetailedGameScoring(
                context,
                'Speed Tap',
                'Points = 1000 - Reaction Time (ms)\n'
                    '• 200ms reaction = 800 points\n'
                    '• 300ms reaction = 700 points\n'
                    '• False start = -150 points'),
            _buildDetailedGameScoring(
                context,
                'Memory Grid',
                'Correct answer = +80 points\n'
                    'Wrong answer = -40 points\n'
                    '• Perfect round = +80 per tile\n'
                    '• Mixed performance = net score'),
            _buildDetailedGameScoring(
                context,
                'N-Back',
                'Hit (correct match) = +120 points\n'
                    'Miss (missed match) = -60 points\n'
                    'False alarm = -80 points\n'
                    '• Accuracy is key for high scores'),
            _buildDetailedGameScoring(
                context,
                'Arithmetic Sprint',
                'Correct answer = +90 points\n'
                    'Wrong answer = -60 points\n'
                    '• Speed bonus for quick answers\n'
                    '• Consecutive correct = streak bonus'),
            _buildDetailedGameScoring(
                context,
                'Symbol Search',
                'Correct identification = +100 points\n'
                    'Wrong identification = -70 points\n'
                    '• Higher penalty encourages accuracy'),
            _buildDetailedGameScoring(
                context,
                'Trail Connect',
                'Points = Par Time - Your Time - (Errors × 200)\n'
                    '• Faster completion = more points\n'
                    '• Each error costs 200 points\n'
                    '• Can go negative with many errors'),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitiveSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.leaderboard,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Getting Competitive',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to compete? Here\'s how to improve:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(context, 'Consistency Matters',
                'Regular practice improves your rating more than occasional high scores'),
            _buildBulletPoint(context, 'Focus on Accuracy',
                'Wrong answers hurt your rating more than slow correct answers'),
            _buildBulletPoint(context, 'Challenge Yourself',
                'As your rating increases, games automatically get harder'),
            _buildBulletPoint(context, 'Track Progress',
                'Watch both your Best scores and Ratings improve over time'),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedGameScoring(
      BuildContext context, String game, String details) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
