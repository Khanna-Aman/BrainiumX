import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';

import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/workout/workout_screen.dart';
import 'features/games/game_screen.dart';
import 'features/games/difficulty_selection_screen.dart';

import 'features/settings/settings_screen.dart';
import 'features/help/scoring_help_screen.dart';
import 'features/help/rating_help_screen.dart';
import 'features/help/elo_help_screen.dart';
import 'features/help/games_help_screen.dart';
import 'features/help/domains_help_screen.dart';
import 'data/models/models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userProfile = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      if (userProfile == null && !isOnSplash && !isOnOnboarding) {
        return '/onboarding';
      }

      if (userProfile != null && (isOnSplash || isOnOnboarding)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/workout',
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '/difficulty/:id',
        builder: (context, state) {
          final gameIdStr = state.pathParameters['id']!;
          final gameId = GameId.values.firstWhere(
            (g) => g.name == gameIdStr,
            orElse: () => GameId.speedTap,
          );

          // Speed Tap bypasses difficulty selection
          if (gameId == GameId.speedTap) {
            return GameScreen(gameId: gameId, difficulty: null);
          }

          return DifficultySelectionScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: '/game/:id',
        builder: (context, state) {
          final gameIdStr = state.pathParameters['id']!;
          final difficultyStr = state.uri.queryParameters['difficulty'];
          final gameId = GameId.values.firstWhere(
            (g) => g.name == gameIdStr,
            orElse: () => GameId.speedTap,
          );

          DifficultyLevel? difficulty;
          if (difficultyStr != null) {
            difficulty = DifficultyLevel.values.firstWhere(
              (d) => d.name == difficultyStr,
              orElse: () => DifficultyLevel.medium,
            );
          }

          return GameScreen(gameId: gameId, difficulty: difficulty);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/scoring-help',
        builder: (context, state) => const ScoringHelpScreen(),
      ),
      GoRoute(
        path: '/rating-help',
        builder: (context, state) => const RatingHelpScreen(),
      ),
      GoRoute(
        path: '/elo-help',
        builder: (context, state) => const EloHelpScreen(),
      ),
      GoRoute(
        path: '/games-help',
        builder: (context, state) => const GamesHelpScreen(),
      ),
      GoRoute(
        path: '/domains-help',
        builder: (context, state) => const DomainsHelpScreen(),
      ),
    ],
  );
});

class BrainiumXApp extends ConsumerWidget {
  const BrainiumXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Set system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? AppTheme.darkSystemUiOverlayStyle
          : AppTheme.lightSystemUiOverlayStyle,
    );

    return MaterialApp.router(
      title: 'BrainiumX - Brain Training Games',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Ensure proper handling of system UI overlays and text scaling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Ensure text scaling doesn't break layouts
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
