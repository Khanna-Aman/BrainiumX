// Utility class to help convert games to BaseGame architecture
// This file contains common patterns and helpers for game conversion

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import 'object_pool.dart';

class GameConverter {
  // Common timer creation with safety checks
  static Timer createSafeTimer(
    Duration duration,
    VoidCallback callback, {
    required bool Function() mounted,
    required bool Function() gameEnded,
  }) {
    return Timer(duration, () {
      if (mounted() && !gameEnded()) {
        try {
          callback();
        } catch (error, stackTrace) {
          debugPrint('Timer callback error: $error\n$stackTrace');
        }
      }
    });
  }

  // Common periodic timer creation with safety checks
  static Timer createSafePeriodicTimer(
    Duration duration,
    void Function(Timer) callback, {
    required bool Function() mounted,
    required bool Function() gameEnded,
    required bool Function() gamePaused,
  }) {
    late Timer timer;
    timer = Timer.periodic(duration, (t) {
      if (mounted() && !gameEnded() && !gamePaused()) {
        try {
          callback(t);
        } catch (error, stackTrace) {
          debugPrint('Periodic timer callback error: $error\n$stackTrace');
          t.cancel();
        }
      }
    });
    return timer;
  }

  // Common patterns for game state management
  static void safeSetState(
    VoidCallback callback, {
    required bool Function() mounted,
  }) {
    if (mounted()) {
      callback();
    }
  }

  // Common scoring patterns
  static void addScoreWithFeedback(
    double score,
    void Function(int) addScore,
  ) {
    addScore(score.toInt());
  }

  // Common accuracy calculation
  static double calculateAccuracy(
    List<bool> responses,
    List<bool> correctAnswers,
  ) {
    if (responses.isEmpty || correctAnswers.isEmpty) return 0.0;

    final correct = responses
        .asMap()
        .entries
        .where((entry) =>
            entry.key < correctAnswers.length &&
            correctAnswers[entry.key] == entry.value)
        .length;

    return correct / responses.length;
  }

  // Common UI patterns
  static Widget buildGameHeader({
    required String title,
    required int currentRound,
    required int totalRounds,
    required int remainingTime,
    required double totalScore,
  }) {
    return Container(
      padding: const EdgeInsets.all(GameConstants.cardPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$title: ${currentRound + 1}/$totalRounds',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              'Time: $remainingTime s',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              'Score: ${totalScore.toInt()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Common game end patterns
  static void endGameSafely(
    void Function() endGame,
    Timer? gameTimer,
    List<Timer?> otherTimers,
  ) {
    gameTimer?.cancel();
    for (final timer in otherTimers) {
      timer?.cancel();
    }
    endGame();
  }

  // Resource cleanup patterns
  static void cleanupResources({
    List<Timer?>? timers,
    List<List<dynamic>>? pooledLists,
    Stopwatch? stopwatch,
  }) {
    // Cancel timers
    if (timers != null) {
      for (final timer in timers) {
        timer?.cancel();
      }
    }

    // Stop stopwatch
    stopwatch?.stop();

    // Release pooled resources
    if (pooledLists != null) {
      for (final list in pooledLists) {
        if (list is List<bool>) {
          BoolPool.releaseResponseList(list);
        } else if (list is List<int>) {
          IntPool.releaseIntList(list);
        } else if (list is List<Color>) {
          ColorPool.releaseSequence(list);
        }
      }
    }
  }

  // Common difficulty configuration patterns
  static void configureDifficultyFromProvider(
    dynamic difficulty,
    dynamic Function(dynamic) getConfig,
    void Function(int) setTotalRounds,
    void Function(int) setTimeLimit,
    Map<String, dynamic>? gameSpecific,
  ) {
    if (difficulty != null) {
      final difficultyConfig = getConfig(difficulty);
      setTotalRounds(difficultyConfig.rounds);
      setTimeLimit(difficultyConfig.timeLimit);

      // Apply game-specific configurations
      if (gameSpecific != null && difficultyConfig.gameSpecific != null) {
        for (final entry in difficultyConfig.gameSpecific.entries) {
          if (gameSpecific.containsKey(entry.key)) {
            gameSpecific[entry.key] = entry.value;
          }
        }
      }
    }
  }

  // Common stimulus display patterns
  static Timer showStimulusWithCallback(
    Duration displayTime,
    VoidCallback onShow,
    VoidCallback onHide,
    VoidCallback? onComplete, {
    required bool Function() mounted,
    required bool Function() gameEnded,
    Duration? responseWindow,
  }) {
    onShow();

    return Timer(displayTime, () {
      if (mounted() && !gameEnded()) {
        onHide();

        if (responseWindow != null && onComplete != null) {
          Timer(responseWindow, () {
            if (mounted() && !gameEnded()) {
              onComplete();
            }
          });
        } else if (onComplete != null) {
          onComplete();
        }
      }
    });
  }

  // Common response handling patterns
  static void handleResponse(
    bool isCorrect,
    void Function(int) addScore,
    void Function(bool) recordResponse, {
    int correctScore = 100,
    int incorrectScore = 0,
  }) {
    recordResponse(isCorrect);
    addScore(isCorrect ? correctScore : incorrectScore);
  }

  // Common grid generation patterns
  static List<T> generateRandomSequence<T>(
    List<T> options,
    int length,
    Random random,
  ) {
    final sequence = <T>[];
    for (int i = 0; i < length; i++) {
      sequence.add(options[random.nextInt(options.length)]);
    }
    return sequence;
  }

  // Common position generation for grid games
  static List<int> generateRandomPositions(
    int gridSize,
    int count,
    Random random,
  ) {
    final positions = <int>[];
    final totalPositions = gridSize * gridSize;

    while (positions.length < count) {
      final position = random.nextInt(totalPositions);
      if (!positions.contains(position)) {
        positions.add(position);
      }
    }

    return positions;
  }
}
