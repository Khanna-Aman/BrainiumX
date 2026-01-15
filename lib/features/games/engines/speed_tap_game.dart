import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/providers/game_configs_provider.dart';

class SpeedTapGame extends BaseGame {
  const SpeedTapGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<SpeedTapGame> createState() => _SpeedTapGameState();
}

class _SpeedTapGameState extends BaseGameState<SpeedTapGame> {
  late Random _random;
  Timer? _stimulusTimer;

  bool _showStimulus = false;
  bool _waitingForTap = false;

  int _currentTrial = 0;

  final List<int> _reactionTimes = [];
  final List<bool> _falseStarts = [];
  double _totalScore = 0;

  DateTime? _stimulusStartTime;

  @override
  void initState() {
    super.initState();
    _random = Random();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getSpeedTapConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _startNextTrial();
  }

  @override
  void onGamePaused() {
    _stimulusTimer?.cancel();
  }

  @override
  void onGameResumed() {
    // Resume target generation if needed
  }

  @override
  Widget buildStartScreen() {
    return _buildInstructions();
  }

  @override
  Widget buildGameScreen() {
    return _buildGameArea();
  }

  @override
  Widget buildEndScreen() {
    return _buildResults();
  }

  String _getLastReactionTimeText() {
    if (_reactionTimes.isEmpty) {
      return 'React Time: --';
    }
    final lastTime = _reactionTimes.last;
    return 'Last: ${lastTime}ms';
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            'Speed Tap',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Wait for the screen to turn GREEN\n'
            '• Tap as quickly as possible when it turns green\n'
            '• Don\'t tap before it turns green (false start!)\n'
            '• Complete 10 trials as fast as you can',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Start Game', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    Color backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    String message = 'Wait...';
    Color textColor = Theme.of(context).colorScheme.onSurface;

    if (_showStimulus) {
      backgroundColor = Colors.green;
      message = 'TAP NOW!';
      textColor = Colors.white;
    } else if (_waitingForTap) {
      backgroundColor = Colors.red;
      message = 'Too early!';
      textColor = Colors.white;
    }

    return ResponsiveWrapper(
      child: Column(
        children: [
          // HUD
          Container(
            padding:
                ResponsiveUtils.getScreenPadding(context).copyWith(bottom: 0),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Trial: $_currentTrial/$totalRounds',
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Time: ${remainingTime.toStringAsFixed(0)} s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _getLastReactionTimeText(),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Game Area
          Expanded(
            child: Padding(
              padding: ResponsiveUtils.getScreenPadding(context)
                  .copyWith(top: 0, bottom: 0),
              child: GestureDetector(
                onTap: _handleTap,
                onPanEnd: (details) {
                  // Any swipe gesture also counts as a tap for speed
                  if (details.velocity.pixelsPerSecond.distance > 200) {
                    _handleTap();
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                  child: Center(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize:
                            switch (ResponsiveUtils.getDeviceType(context)) {
                                  DeviceType.mobile => 36.0,
                                  DeviceType.tablet => 48.0,
                                  DeviceType.desktop => 60.0,
                                } *
                                ResponsiveUtils.getFontScale(context),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final validTaps = _falseStarts.where((fs) => !fs).length;
    final accuracy = SafeMath.safeAccuracy(validTaps, totalRounds);
    final avgReactionTime = _reactionTimes.isNotEmpty
        ? SafeMath.safeDivision(
            _reactionTimes.reduce((a, b) => a + b), _reactionTimes.length)
        : 0.0;
    final (congratsMessage, encouragementMessage) =
        _getCongratulationsMessage(avgReactionTime, accuracy);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 24),
          Text(
            congratsMessage,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            encouragementMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _resultRow('Score', _totalScore.toInt().toString()),
                  _resultRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                  _resultRow(
                      'Avg Reaction Time', '${avgReactionTime.toInt()} ms'),
                  _resultRow('Trials Completed', '$_currentTrial'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    startGame();
  }

  @override
  void onGameEnded() {
    // Speed Tap only tracks best reaction time, not ELO rating
    // Just update the high score (best reaction time) without ELO calculation
    final validReactionTimes = _reactionTimes.where((rt) => rt > 0).toList();
    if (validReactionTimes.isNotEmpty) {
      final bestReactionTime =
          validReactionTimes.reduce((a, b) => a < b ? a : b);

      // Update high score directly without going through ELO system
      final gameConfigsNotifier = ref.read(gameConfigsProvider.notifier);
      gameConfigsNotifier.updateHighScore(
          widget.gameId, bestReactionTime.toDouble());
    }

    // End the game without recording session result for ELO
    _endGame();
  }

  void _endGame() {
    endGame();
  }

  void _startNextTrial() {
    if (_currentTrial >= totalRounds) {
      endGame();
      return;
    }

    setState(() {
      _currentTrial++;
      _showStimulus = false;
      _waitingForTap = false;
    });

    // Random delay between configured min and max
    final minWait = GameTimingConfig.speedTapMinWait.inMilliseconds;
    final maxWait = GameTimingConfig.speedTapMaxWait.inMilliseconds;
    final delay = _random.nextInt(maxWait - minWait) + minWait;

    _stimulusTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted && !gameEnded) {
        setState(() {
          _showStimulus = true;
          _stimulusStartTime = DateTime.now();
        });
      }
    });
  }

  void _handleTap() {
    if (gameEnded) return;

    if (!_showStimulus) {
      // False start
      setState(() {
        _waitingForTap = true;
      });

      _falseStarts.add(true);
      _reactionTimes.add(0);
      _totalScore += 0; // No points for false start

      addTimer(GameTimingConfig.falseStartPenalty, () {
        _currentTrial++;
        _startNextTrial();
      });
    } else {
      // Valid tap
      final reactionTime =
          DateTime.now().difference(_stimulusStartTime!).inMilliseconds;

      _falseStarts.add(false);
      _reactionTimes.add(reactionTime);

      // Simple scoring: faster = better (max 1000 points for <200ms)
      final points = (1000 - reactionTime).clamp(0, 1000);
      _totalScore += points;

      _startNextTrial();
    }
  }

  Widget _resultRow(String label, String value) {
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

  (String, String) _getCongratulationsMessage(
      double avgReactionTime, double accuracy) {
    // For Speed Tap, focus on reaction time (lower is better)
    if (avgReactionTime <= 200 && accuracy >= 0.9) {
      return ('Lightning Fast', 'Incredible reflexes! You\'re a speed demon!');
    } else if (avgReactionTime <= 250 && accuracy >= 0.8) {
      return ('Super Quick', 'Amazing speed! Your reflexes are outstanding!');
    } else if (avgReactionTime <= 300 && accuracy >= 0.7) {
      return (
        'Great Reflexes',
        'Excellent reaction time! You\'re getting faster!'
      );
    } else if (avgReactionTime <= 400 && accuracy >= 0.6) {
      return (
        'Good Speed',
        'Nice reflexes! Keep practicing to get even faster!'
      );
    } else if (accuracy >= 0.8) {
      return (
        'Accurate Tapper',
        'Great accuracy! Focus on speed for even better results!'
      );
    } else {
      return (
        'Keep Practicing',
        'Your reflexes will improve with practice! Stay focused!'
      );
    }
  }
}
