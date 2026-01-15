import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../data/models/models.dart';
import '../../core/utils/responsive_utils.dart';

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
                Icons.sports_esports,
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
          // Settings Button
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
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Play Section
                Text(
                  'Quick Play',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize! *
                            ResponsiveUtils.getFontScale(context),
                      ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),

                Consumer(
                  builder: (context, ref, child) {
                    final gameConfigs = ref.watch(gameConfigsProvider);

                    // Show loading indicator if configs are not loaded yet
                    if (gameConfigs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(
                              context,
                              type: SpacingType.large)),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    return ResponsiveGrid(
                      children: GameId.values
                          .map((gameId) => _GameCard(gameId: gameId))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
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
    try {
      final gameConfigs = ref.watch(gameConfigsProvider);
      final config = gameConfigs.firstWhere(
        (c) => c.gameId == gameId,
        orElse: () => GameConfig(gameId: gameId),
      );

      // If gameConfigs is empty, show loading
      if (gameConfigs.isEmpty) {
        return Card(
          child: Center(
            child: Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }

      // For Speed Tap, show best reaction time instead of score
      String bestText;
      if (gameId == GameId.speedTap) {
        // Speed Tap stores best reaction time in highScore
        if (config.highScore > 0) {
          bestText = 'Best: ${config.highScore.toInt()} ms';
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
                // Only show rating for games that use ELO system (not Speed Tap)
                if (gameId != GameId.speedTap)
                  Text(
                    'Rating: ${config.difficultyRating.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Return a safe fallback card if any error occurs
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                gameId.icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                gameId.displayName,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
