import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../data/models/models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BrainiumX',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Hello, ${userProfile?.displayName ?? 'User'}!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => context.push('/scoring-help'),
              tooltip: 'Scoring Help',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => context.push('/settings'),
            ),
          ),
        ],
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
              // Quick Play Section
              Text(
                'Quick Play',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: GameId.values.length,
                itemBuilder: (context, index) {
                  final gameId = GameId.values[index];
                  return _GameCard(gameId: gameId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends ConsumerWidget {
  final GameId gameId;

  const _GameCard({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameConfigs = ref.watch(gameConfigsProvider);
    final config = gameConfigs.firstWhere((c) => c.gameId == gameId);
    final sessionResults = ref.watch(sessionResultsProvider);

    // For Speed Tap, show best reaction time instead of score
    String bestText;
    if (gameId == GameId.speedTap) {
      final speedTapResults = sessionResults
          .where((r) => r.gameId == GameId.speedTap && r.reactionTime != null)
          .toList();

      if (speedTapResults.isNotEmpty) {
        final bestReactionTime = speedTapResults
            .map((r) => r.reactionTime!)
            .reduce((a, b) => a < b ? a : b);
        bestText = 'Best: ${bestReactionTime.toInt()} ms';
      } else {
        bestText = 'Best: -- ms';
      }
    } else {
      bestText = 'Best: ${config.highScore.toInt()}';
    }

    return Card(
      child: InkWell(
        onTap: () => context.push('/difficulty/${gameId.name}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameId.displayName,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                bestText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Rating: ${config.difficultyRating.toInt()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
