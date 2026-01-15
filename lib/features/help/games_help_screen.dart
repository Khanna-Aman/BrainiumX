import 'package:flutter/material.dart';

class GamesHelpScreen extends StatelessWidget {
  const GamesHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'How Games Work',
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.games,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'All 12 Cognitive Games',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'BrainiumX features 12 scientifically-designed cognitive games that test and train different aspects of your mental abilities. Each game targets specific cognitive domains and provides detailed performance metrics.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Speed & Attention Games
              _buildGameCategory(
                context,
                'Speed & Attention Games',
                Icons.flash_on,
                [
                  _GameInfo(
                    'Speed Tap',
                    'Tap targets as quickly as possible when they appear',
                    'Tests: Reaction time, visual attention, motor speed',
                    'Scoring: Speed + accuracy of target detection',
                  ),
                  _GameInfo(
                    'Trail Connect',
                    'Connect numbered circles in ascending order',
                    'Tests: Visual scanning, attention switching, processing speed',
                    'Scoring: Completion time + path efficiency',
                  ),
                  _GameInfo(
                    'Color Dominance',
                    'Find which color appears most frequently in a grid of colored squares',
                    'Tests: Visual attention, frequency detection, pattern recognition',
                    'Scoring: Accuracy of color frequency identification',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Memory & Pattern Games
              _buildGameCategory(
                context,
                'Memory & Pattern Games',
                Icons.memory,
                [
                  _GameInfo(
                    'Number Sequence',
                    'Find patterns in number sequences and predict the next number',
                    'Tests: Pattern recognition, logical reasoning, mathematical thinking',
                    'Scoring: Correct predictions + sequence complexity bonus',
                  ),
                  _GameInfo(
                    'Memory Grid',
                    'Remember and reproduce sequences of highlighted grid positions',
                    'Tests: Spatial memory, sequence recall, visual attention',
                    'Scoring: Sequence accuracy × length bonus',
                  ),
                  _GameInfo(
                    'Color Match',
                    'Watch color sequences and repeat them in the same order',
                    'Tests: Sequential memory, visual attention, working memory',
                    'Scoring: Sequence accuracy × length bonus',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Inhibition & Control Games
              _buildGameCategory(
                context,
                'Inhibition & Control Games',
                Icons.block,
                [
                  _GameInfo(
                    'Stroop Match',
                    'Identify if word meaning matches text color, ignoring interference',
                    'Tests: Cognitive inhibition, attention control, interference resolution',
                    'Scoring: Correct responses - interference errors',
                  ),
                  _GameInfo(
                    'Go/No-Go',
                    'Respond to "go" stimuli while avoiding "no-go" stimuli',
                    'Tests: Impulse control, response inhibition, sustained attention',
                    'Scoring: Correct responses - false positives',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Reasoning & Flexibility Games
              _buildGameCategory(
                context,
                'Reasoning & Flexibility Games',
                Icons.psychology,
                [
                  _GameInfo(
                    'Spatial Rotation',
                    'Determine if rotated shapes match the original',
                    'Tests: Mental rotation, spatial reasoning, visual processing',
                    'Scoring: Accuracy × rotation complexity',
                  ),
                  _GameInfo(
                    'Focus Shift',
                    'Switch between different tasks and respond to changing rules',
                    'Tests: Cognitive flexibility, attention switching, task management',
                    'Scoring: Correct responses × switching efficiency',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Processing & Verbal Games
              _buildGameCategory(
                context,
                'Processing & Verbal Games',
                Icons.speed,
                [
                  _GameInfo(
                    'Arithmetic Sprint',
                    'Solve math problems as quickly and accurately as possible',
                    'Tests: Processing speed, numerical reasoning, mental calculation',
                    'Scoring: Correct answers × speed factor',
                  ),
                  _GameInfo(
                    'Word Chain',
                    'Create word chains by changing one letter at a time',
                    'Tests: Verbal fluency, vocabulary, creative thinking',
                    'Scoring: Valid connections × category bonus',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Difficulty Levels
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Difficulty Levels',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                          '1️⃣ Very Easy: 3-5 rounds, relaxed timing, perfect for testing'),
                      const SizedBox(height: 4),
                      const Text(
                          '2️⃣ Easy: 5-8 rounds, comfortable pace, good for beginners'),
                      const SizedBox(height: 4),
                      const Text(
                          '3️⃣ Medium: 8-12 rounds, standard challenge, full features'),
                      const SizedBox(height: 4),
                      const Text(
                          '4️⃣ Hard: 12+ rounds, fast pace, maximum cognitive challenge'),
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

  Widget _buildGameCategory(BuildContext context, String title, IconData icon,
      List<_GameInfo> games) {
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...games.map((game) => _buildGameInfo(context, game)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo(BuildContext context, _GameInfo game) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            game.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            game.tests,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            game.scoring,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _GameInfo {
  final String name;
  final String description;
  final String tests;
  final String scoring;

  _GameInfo(this.name, this.description, this.tests, this.scoring);
}
