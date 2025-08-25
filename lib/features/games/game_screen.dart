import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import 'engines/speed_tap_game.dart';
import 'engines/stroop_match_game.dart';
import 'engines/n_back_game.dart';
import 'engines/memory_grid_game.dart';
import 'engines/spatial_rotation_game.dart';
import 'engines/trail_connect_game.dart';
import 'engines/go_no_go_game.dart';
import 'engines/symbol_search_game.dart';
import 'engines/arithmetic_sprint_game.dart';
import 'engines/pattern_matrix_game.dart';
import 'engines/word_chain_game.dart';
import 'engines/visual_search_game.dart';

class GameScreen extends ConsumerWidget {
  final GameId gameId;

  const GameScreen({super.key, required this.gameId});

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
      body: _buildGameWidget(),
    );
  }

  Widget _buildGameWidget() {
    switch (gameId) {
      case GameId.speedTap:
        return SpeedTapGame(gameId: gameId);
      case GameId.stroopMatch:
        return StroopMatchGame(gameId: gameId);
      case GameId.nBack:
        return NBackGame(gameId: gameId);
      case GameId.memoryGrid:
        return MemoryGridGame(gameId: gameId);
      case GameId.spatialRotation:
        return SpatialRotationGame(gameId: gameId);
      case GameId.trailConnect:
        return TrailConnectGame(gameId: gameId);
      case GameId.goNoGo:
        return GoNoGoGame(gameId: gameId);
      case GameId.symbolSearch:
        return SymbolSearchGame(gameId: gameId);
      case GameId.arithmeticSprint:
        return ArithmeticSprintGame(gameId: gameId);
      case GameId.patternMatrix:
        return PatternMatrixGame(gameId: gameId);
      case GameId.wordChain:
        return WordChainGame(gameId: gameId);
      case GameId.visualSearch:
        return VisualSearchGame(gameId: gameId);
    }
  }
}
