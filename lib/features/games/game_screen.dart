import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import 'difficulty_selection_screen.dart';
import 'engines/speed_tap_game.dart';
import 'engines/stroop_match_game.dart';
import 'engines/n_back_game.dart';
import 'engines/memory_grid_game.dart';
import 'engines/spatial_rotation_game.dart';
import 'engines/trail_connect_game.dart';
import 'engines/go_no_go_game.dart';
import 'engines/color_match_game.dart';
import 'engines/arithmetic_sprint_game.dart';
import 'engines/pattern_matrix_game.dart';
import 'engines/word_chain_game.dart';
import 'engines/visual_search_game.dart';

class GameScreen extends ConsumerWidget {
  final GameId gameId;
  final DifficultyLevel? difficulty;

  const GameScreen({super.key, required this.gameId, this.difficulty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameId.displayName),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _buildGameWidget(),
      ),
    );
  }

  Widget _buildGameWidget() {
    switch (gameId) {
      case GameId.speedTap:
        return SpeedTapGame(gameId: gameId, difficulty: difficulty);
      case GameId.stroopMatch:
        return StroopMatchGame(gameId: gameId, difficulty: difficulty);
      case GameId.nBack:
        return NBackGame(gameId: gameId, difficulty: difficulty);
      case GameId.memoryGrid:
        return MemoryGridGame(gameId: gameId, difficulty: difficulty);
      case GameId.spatialRotation:
        return SpatialRotationGame(gameId: gameId, difficulty: difficulty);
      case GameId.trailConnect:
        return TrailConnectGame(gameId: gameId, difficulty: difficulty);
      case GameId.goNoGo:
        return GoNoGoGame(gameId: gameId, difficulty: difficulty);
      case GameId.colorMatch:
        return ColorMatchGame(gameId: gameId, difficulty: difficulty);
      case GameId.arithmeticSprint:
        return ArithmeticSprintGame(gameId: gameId, difficulty: difficulty);
      case GameId.patternMatrix:
        return PatternMatrixGame(gameId: gameId, difficulty: difficulty);
      case GameId.wordChain:
        return WordChainGame(gameId: gameId, difficulty: difficulty);
      case GameId.visualSearch:
        return VisualSearchGame(gameId: gameId, difficulty: difficulty);
    }
  }
}
