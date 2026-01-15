import 'package:flutter/material.dart';

class EloHelpScreen extends StatelessWidget {
  const EloHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ELO System',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
              // Introduction
              _buildSection(
                context,
                'What is ELO Rating?',
                Icons.info,
                [
                  'ELO is a rating system originally designed for chess',
                  'It calculates skill level based on performance against others',
                  'Higher ratings indicate better cognitive performance',
                  'Your rating changes based on game results and accuracy',
                  'The system adapts to your improving skills over time',
                ],
              ),

              const SizedBox(height: 16),

              // How it works
              _buildSection(
                context,
                'How ELO Calculation Works',
                Icons.calculate,
                [
                  'Expected Score = 1 / (1 + 10^((Opponent - Your Rating) / 400))',
                  'Rating Change = K-Factor × (Actual Score - Expected Score)',
                  'K-Factor = 32 for new players, 16 for experienced players',
                  'Actual Score = 1 for win, 0.5 for draw, 0 for loss',
                  'In BrainiumX, "opponent" is the game difficulty level',
                ],
              ),

              const SizedBox(height: 16),

              // Factors affecting rating
              _buildSection(
                context,
                'Factors Affecting Your Rating',
                Icons.psychology,
                [
                  'Game Performance: Accuracy and speed in each game',
                  'Consistency: Regular high performance vs occasional peaks',
                  'Difficulty Level: Higher difficulty games impact rating more',
                  'Game Type: Different cognitive domains have separate ratings',
                  'Learning Curve: New players see faster rating changes',
                  'Plateau Effect: Rating changes slow as you improve',
                ],
              ),

              const SizedBox(height: 16),

              // Tips for improvement
              _buildSection(
                context,
                'Tips to Improve Your Rating',
                Icons.lightbulb,
                [
                  'Practice regularly: Consistent training improves performance',
                  'Focus on accuracy: Correct answers matter more than speed',
                  'Challenge yourself: Try higher difficulty levels gradually',
                  'Analyze patterns: Learn from mistakes and successes',
                  'Stay patient: Rating improvements take time and practice',
                  'Cross-train: Play different games to develop all cognitive areas',
                ],
              ),

              const SizedBox(height: 16),

              // Mathematical example
              _buildSection(
                context,
                'Example Calculation',
                Icons.functions,
                [
                  'Player Rating: 1200, Game Difficulty: 1300',
                  'Expected Score = 1 / (1 + 10^((1300-1200)/400)) = 0.36',
                  'If you score 80% accuracy: Actual Score = 0.8',
                  'Rating Change = 16 × (0.8 - 0.36) = +7 points',
                  'New Rating: 1200 + 7 = 1207',
                  'Better performance = higher rating gain!',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, IconData icon, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          )),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
