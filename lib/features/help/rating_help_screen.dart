import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RatingHelpScreen extends StatelessWidget {
  const RatingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating System'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
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
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ELO Rating System',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your cognitive performance is measured using a professional ELO rating system, similar to chess rankings.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // How Rating Works
              _buildSection(
                context,
                'How Rating Works',
                Icons.psychology,
                [
                  'Your rating starts at 1200 points',
                  'Each game performance affects your rating',
                  'Better performance = higher rating gain',
                  'Poor performance = rating loss',
                  'Rating stabilizes as you play more games',
                ],
              ),

              const SizedBox(height: 16),

              // Rating Calculation
              _buildSection(
                context,
                'Rating Calculation',
                Icons.calculate,
                [
                  'Expected Score: Based on your current rating',
                  'Actual Score: Your game performance (0-100%)',
                  'K-Factor: 32 (determines rating change speed)',
                  'Formula: New Rating = Old Rating + K × (Actual - Expected)',
                ],
              ),

              const SizedBox(height: 16),

              // Game-Specific Scoring
              _buildSection(
                context,
                'Game-Specific Scoring',
                Icons.games,
                [
                  'Speed Tap: Reaction time consistency + accuracy',
                  'Stroop Match: Correct responses - interference errors',
                  'Number Sequence: Pattern recognition + prediction accuracy',
                  'Spatial Rotation: Accuracy × rotation complexity',
                  'Memory Grid: Sequence accuracy × speed bonus',
                  'Trail Connect: Path efficiency + completion time',
                  'Go/No-Go: Correct responses - false positives',
                  'Color Match: Sequence accuracy × length bonus',
                  'Arithmetic Sprint: Correct answers × speed factor',
                  'Focus Shift: Task switching accuracy + flexibility',
                  'Word Chain: Valid connections × category bonus',
                  'Color Dominance: Frequency detection accuracy',
                ],
              ),

              const SizedBox(height: 16),

              // Detailed Scoring Explanations
              _buildSection(
                context,
                'Detailed Scoring Methodology',
                Icons.analytics,
                [
                  'Speed Tap: Measures reaction time and accuracy. Faster, more accurate taps = higher score.',
                  'Stroop Match: Tests cognitive inhibition. Correct color-word matches boost rating.',
                  'Number Sequence: Pattern recognition assessment. Correct predictions increase score significantly.',
                  'Spatial Rotation: Mental rotation ability. Complex rotations correctly identified earn more points.',
                  'Memory Grid: Spatial memory test. Longer sequences remembered accurately = higher rating.',
                  'Trail Connect: Executive function. Efficient path completion with minimal errors scores best.',
                  'Go/No-Go: Impulse control. Correct responses to "go" stimuli, avoiding "no-go" errors.',
                  'Color Match: Sequential memory. Longer color sequences reproduced accurately earn more.',
                  'Arithmetic Sprint: Processing speed. Quick, accurate math calculations boost cognitive rating.',
                  'Focus Shift: Cognitive flexibility. Accurate task switching and rule adaptation skills.',
                  'Word Chain: Verbal fluency. Creative word connections and category knowledge.',
                  'Color Dominance: Visual attention. Accurately identifying most frequent colors in grids.',
                ],
              ),

              const SizedBox(height: 16),

              // Cognitive Domains
              _buildSection(
                context,
                'Cognitive Domains Assessed',
                Icons.psychology,
                [
                  'Speed & Attention: Speed Tap, Trail Connect, Color Dominance',
                  'Memory: Number Sequence, Memory Grid, Color Match',
                  'Inhibition & Control: Stroop Match, Go/No-Go',
                  'Spatial Reasoning: Spatial Rotation',
                  'Cognitive Flexibility: Focus Shift',
                  'Verbal Skills: Word Chain',
                  'Processing Speed: Arithmetic Sprint',
                  'Executive Function: Trail Connect, Go/No-Go, Focus Shift',
                  'Working Memory: Number Sequence, Color Match',
                  'Visual Attention: Color Dominance, Stroop Match',
                ],
              ),

              const SizedBox(height: 16),

              // Tips for Improvement
              _buildSection(
                context,
                'Tips for Improvement',
                Icons.tips_and_updates,
                [
                  'Play regularly to maintain cognitive fitness',
                  'Focus on accuracy over speed initially',
                  'Try different difficulty levels',
                  'Review your performance analytics',
                  'Take breaks to avoid mental fatigue',
                ],
              ),

              const SizedBox(height: 24),

              // Footer
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your rating reflects your cognitive performance across all games. Keep playing to see improvement!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, IconData icon, List<String> points) {
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...points.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                      Expanded(
                        child: Text(
                          point,
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
