import '../../data/models/models.dart';
import '../../features/games/difficulty_selection_screen.dart';

/// Configuration class for game difficulty parameters
class GameDifficultyConfig {
  final int rounds;
  final int timeLimit;
  final double complexity;
  final Map<String, dynamic> gameSpecific;

  const GameDifficultyConfig({
    required this.rounds,
    required this.timeLimit,
    required this.complexity,
    this.gameSpecific = const {},
  });
}

/// Provides difficulty configurations for all games
class DifficultyConfigProvider {
  /// Get configuration for Speed Tap game
  static GameDifficultyConfig getSpeedTapConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 15,
          complexity: 0.2,
          gameSpecific: {
            'targetCount': 5,
            'timePerTarget': 3000,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 20,
          complexity: 0.4,
          gameSpecific: {
            'targetCount': 8,
            'timePerTarget': 2500,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 30,
          complexity: 0.6,
          gameSpecific: {
            'targetCount': 12,
            'timePerTarget': 2000,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 40,
          complexity: 0.8,
          gameSpecific: {
            'targetCount': 18,
            'timePerTarget': 1500,
          },
        );
    }
  }

  /// Get configuration for Stroop Match game
  static GameDifficultyConfig getStroopMatchConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 30,
          complexity: 0.2,
          gameSpecific: {
            'trials': 8,
            'responseTime': 4000,
            'matchRatio': 0.7,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 45,
          complexity: 0.4,
          gameSpecific: {
            'trials': 12,
            'responseTime': 3500,
            'matchRatio': 0.6,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 60,
          complexity: 0.6,
          gameSpecific: {
            'trials': 16,
            'responseTime': 3000,
            'matchRatio': 0.5,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 75,
          complexity: 0.8,
          gameSpecific: {
            'trials': 24,
            'responseTime': 2500,
            'matchRatio': 0.4,
          },
        );
    }
  }

  /// Get configuration for N-Back game
  static GameDifficultyConfig getNBackConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 30,
          complexity: 0.2,
          gameSpecific: {
            'trials': 8,
            'nLevel': 1,
            'stimulusDuration': 2000,
            'intervalDuration': 1000,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 45,
          complexity: 0.4,
          gameSpecific: {
            'trials': 12,
            'nLevel': 1,
            'stimulusDuration': 1800,
            'intervalDuration': 800,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 60,
          complexity: 0.6,
          gameSpecific: {
            'trials': 15,
            'nLevel': 2,
            'stimulusDuration': 1500,
            'intervalDuration': 600,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 75,
          complexity: 0.8,
          gameSpecific: {
            'trials': 20,
            'nLevel': 2,
            'stimulusDuration': 1200,
            'intervalDuration': 500,
          },
        );
    }
  }

  /// Get configuration for Spatial Rotation game
  static GameDifficultyConfig getSpatialRotationConfig(
      DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 60,
          complexity: 0.2,
          gameSpecific: {
            'trials': 6,
            'gridSize': 3,
            'rotationAngles': [90],
            'responseTime': 10000,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 75,
          complexity: 0.4,
          gameSpecific: {
            'trials': 8,
            'gridSize': 4,
            'rotationAngles': [90, 180],
            'responseTime': 9000,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 80,
          complexity: 0.6,
          gameSpecific: {
            'trials': 12,
            'gridSize': 4,
            'rotationAngles': [90, 180, 270],
            'responseTime': 7000,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 80,
          complexity: 0.8,
          gameSpecific: {
            'trials': 16,
            'gridSize': 5,
            'rotationAngles': [45, 90, 135, 180, 225, 270],
            'responseTime': 5000,
          },
        );
    }
  }

  /// Get configuration for Memory Grid game
  static GameDifficultyConfig getMemoryGridConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 45,
          complexity: 0.2,
          gameSpecific: {
            'gridSize': 3,
            'sequenceLength': 2,
            'showDuration': 2500,
            'trials': 5,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 50,
          complexity: 0.4,
          gameSpecific: {
            'gridSize': 4,
            'sequenceLength': 3,
            'showDuration': 2000,
            'trials': 6,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 60,
          complexity: 0.6,
          gameSpecific: {
            'gridSize': 4,
            'sequenceLength': 5,
            'showDuration': 1500,
            'trials': 8,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 70,
          complexity: 0.8,
          gameSpecific: {
            'gridSize': 5,
            'sequenceLength': 7,
            'showDuration': 1000,
            'trials': 10,
          },
        );
    }
  }

  /// Get configuration for Trail Connect game
  static GameDifficultyConfig getTrailConnectConfig(
      DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 60,
          complexity: 0.2,
          gameSpecific: {
            'nodeCount': 8,
            'timePerTrial': 20000,
            'trials': 3,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 75,
          complexity: 0.4,
          gameSpecific: {
            'nodeCount': 12,
            'timePerTrial': 15000,
            'trials': 4,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 80,
          complexity: 0.6,
          gameSpecific: {
            'nodeCount': 16,
            'timePerTrial': 10000,
            'trials': 5,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 90,
          complexity: 0.8,
          gameSpecific: {
            'nodeCount': 20,
            'timePerTrial': 7000,
            'trials': 6,
          },
        );
    }
  }

  /// Get configuration for Go/No-Go game
  static GameDifficultyConfig getGoNoGoConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 45,
          complexity: 0.2,
          gameSpecific: {
            'trials': 10,
            'goRatio': 0.8,
            'stimulusDuration': 2000,
            'responseWindow': 1500,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 60,
          complexity: 0.4,
          gameSpecific: {
            'trials': 15,
            'goRatio': 0.7,
            'stimulusDuration': 1500,
            'responseWindow': 1200,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 70,
          complexity: 0.6,
          gameSpecific: {
            'trials': 20,
            'goRatio': 0.6,
            'stimulusDuration': 1200,
            'responseWindow': 1000,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 80,
          complexity: 0.8,
          gameSpecific: {
            'trials': 30,
            'goRatio': 0.5,
            'stimulusDuration': 1000,
            'responseWindow': 800,
          },
        );
    }
  }

  /// Get configuration for Color Match game
  static GameDifficultyConfig getColorMatchConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 45,
          complexity: 0.2,
          gameSpecific: {
            'sequenceLength': 3,
            'showDuration': 1200,
            'trials': 5,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 60,
          complexity: 0.4,
          gameSpecific: {
            'sequenceLength': 4,
            'showDuration': 1000,
            'trials': 6,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 90,
          complexity: 0.6,
          gameSpecific: {
            'sequenceLength': 5,
            'showDuration': 800,
            'trials': 8,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 120,
          complexity: 0.8,
          gameSpecific: {
            'sequenceLength': 6,
            'showDuration': 600,
            'trials': 10,
          },
        );
    }
  }

  /// Get configuration for Arithmetic Sprint game
  static GameDifficultyConfig getArithmeticSprintConfig(
      DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 45,
          complexity: 0.2,
          gameSpecific: {
            'questions': 8,
            'maxNumber': 20,
            'operations': ['+', '-'],
            'responseTime': 8000,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 60,
          complexity: 0.4,
          gameSpecific: {
            'questions': 12,
            'maxNumber': 50,
            'operations': ['+', '-', '×'],
            'responseTime': 6000,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 90,
          complexity: 0.6,
          gameSpecific: {
            'questions': 16,
            'maxNumber': 100,
            'operations': ['+', '-', '×', '÷'],
            'responseTime': 5000,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 120,
          complexity: 0.8,
          gameSpecific: {
            'questions': 24,
            'maxNumber': 200,
            'operations': ['+', '-', '×', '÷'],
            'responseTime': 4000,
          },
        );
    }
  }

  /// Get configuration for Focus Shift game
  static GameDifficultyConfig getFocusShiftConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 90,
          complexity: 0.2,
          gameSpecific: {
            'responseTime': 4000,
            'taskSwitchFrequency': 0.3,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 100,
          complexity: 0.4,
          gameSpecific: {
            'responseTime': 3500,
            'taskSwitchFrequency': 0.5,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 120,
          complexity: 0.6,
          gameSpecific: {
            'responseTime': 3000,
            'taskSwitchFrequency': 0.7,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 150,
          complexity: 0.8,
          gameSpecific: {
            'responseTime': 2500,
            'taskSwitchFrequency': 0.8,
          },
        );
    }
  }

  /// Get configuration for Word Chain game
  static GameDifficultyConfig getWordChainConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 60,
          complexity: 0.2,
          gameSpecific: {
            'wordLength': 4,
            'chains': 4,
            'timePerWord': 15000,
            'trials': 3,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 90,
          complexity: 0.4,
          gameSpecific: {
            'wordLength': 5,
            'chains': 5,
            'timePerWord': 12000,
            'trials': 4,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 120,
          complexity: 0.6,
          gameSpecific: {
            'wordLength': 6,
            'chains': 6,
            'timePerWord': 10000,
            'trials': 5,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 150,
          complexity: 0.8,
          gameSpecific: {
            'wordLength': 7,
            'chains': 8,
            'timePerWord': 8000,
            'trials': 6,
          },
        );
    }
  }

  /// Get configuration for Color Dominance game
  static GameDifficultyConfig getColorDominanceConfig(
      DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const GameDifficultyConfig(
          rounds: 3,
          timeLimit: 45,
          complexity: 0.2,
          gameSpecific: {
            'gridSize': 6,
            'symbolTypes': 3,
            'trials': 4,
            'responseTime': 15000,
          },
        );
      case DifficultyLevel.medium:
        return const GameDifficultyConfig(
          rounds: 5,
          timeLimit: 60,
          complexity: 0.4,
          gameSpecific: {
            'gridSize': 7,
            'symbolTypes': 4,
            'trials': 5,
            'responseTime': 12000,
          },
        );
      case DifficultyLevel.hard:
        return const GameDifficultyConfig(
          rounds: 7,
          timeLimit: 90,
          complexity: 0.6,
          gameSpecific: {
            'gridSize': 8,
            'symbolTypes': 4,
            'trials': 6,
            'responseTime': 10000,
          },
        );
      case DifficultyLevel.expert:
        return const GameDifficultyConfig(
          rounds: 10,
          timeLimit: 120,
          complexity: 0.8,
          gameSpecific: {
            'gridSize': 8,
            'symbolTypes': 5,
            'trials': 8,
            'responseTime': 8000,
          },
        );
    }
  }

  /// Get configuration for any game by GameId
  static GameDifficultyConfig getConfigForGame(
      GameId gameId, DifficultyLevel difficulty) {
    switch (gameId) {
      case GameId.speedTap:
        return getSpeedTapConfig(difficulty);
      case GameId.stroopMatch:
        return getStroopMatchConfig(difficulty);
      case GameId.patternSequence:
        return getNBackConfig(difficulty);
      case GameId.spatialRotation:
        return getSpatialRotationConfig(difficulty);
      case GameId.memoryGrid:
        return getMemoryGridConfig(difficulty);
      case GameId.trailConnect:
        return getTrailConnectConfig(difficulty);
      case GameId.goNoGo:
        return getGoNoGoConfig(difficulty);
      case GameId.colorMatch:
        return getColorMatchConfig(difficulty);
      case GameId.arithmeticSprint:
        return getArithmeticSprintConfig(difficulty);
      case GameId.focusShift:
        return getFocusShiftConfig(difficulty);
      case GameId.wordChain:
        return getWordChainConfig(difficulty);
      case GameId.colorDominance:
        return getColorDominanceConfig(difficulty);
    }
  }
}
