import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/utils/difficulty_manager.dart';
import '../../../core/services/audio_service.dart';

class SpeedTapGame extends ConsumerStatefulWidget {
  final GameId gameId;

  const SpeedTapGame({super.key, required this.gameId});

  @override
  ConsumerState<SpeedTapGame> createState() => _SpeedTapGameState();
}

class _SpeedTapGameState extends ConsumerState<SpeedTapGame> {
  late Random _random;
  Timer? _gameTimer;
  Timer? _stimulusTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;
  bool _showStimulus = false;
  bool _waitingForTap = false;

  int _currentTrial = 0;
  int _totalTrials = 10;
  int _timeLimit = 60;
  int _remainingTime = 60;

  List<int> _reactionTimes = [];
  List<bool> _falseStarts = [];
  double _totalScore = 0;

  DateTime? _stimulusStartTime;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _configureDifficulty();
  }

  void _configureDifficulty() {
    // Use rating-based configuration
    final gameConfigs = ref.read(gameConfigsProvider);
    final config = gameConfigs.firstWhere((c) => c.gameId == widget.gameId);
    final rating = config.difficultyRating;

    // Use the new difficulty manager
    final difficultyConfig = DifficultyManager.getSpeedTapConfig(rating);

    _totalTrials = difficultyConfig.totalTrials;
    _timeLimit = difficultyConfig.timeLimit;
    _remainingTime = _timeLimit;
  }

  String _getLastReactionTimeText() {
    if (_reactionTimes.isEmpty) {
      return 'React Time: --';
    }
    final lastTime = _reactionTimes.last;
    return 'Last: ${lastTime}ms';
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _stimulusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildInstructions();
    }

    if (_gameEnded) {
      return _buildResults();
    }

    return _buildGameArea();
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

    return Column(
      children: [
        // HUD
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trial: ${_currentTrial + 1}/$_totalTrials',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Time: $_remainingTime s',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_getLastReactionTimeText(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Game Area
        Expanded(
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
              color: backgroundColor,
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final accuracy = _falseStarts.where((fs) => !fs).length / _totalTrials;
    final avgReactionTime = _reactionTimes.isNotEmpty
        ? _reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length
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
    AudioService.playGameStart();

    setState(() {
      _gameStarted = true;
      _remainingTime = _timeLimit;
    });

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0 || _currentTrial >= _totalTrials) {
        _endGame();
      }
    });

    _startNextTrial();
  }

  void _startNextTrial() {
    if (_currentTrial >= _totalTrials) {
      _endGame();
      return;
    }

    setState(() {
      _showStimulus = false;
      _waitingForTap = false;
    });

    // Get difficulty configuration for wait time
    final gameConfigs = ref.read(gameConfigsProvider);
    final config = gameConfigs.firstWhere((c) => c.gameId == widget.gameId);
    final rating = config.difficultyRating;
    final difficultyConfig = DifficultyManager.getSpeedTapConfig(rating);

    // Random delay based on difficulty
    final delayRange =
        difficultyConfig.maxWaitTime - difficultyConfig.minWaitTime;
    final delay = difficultyConfig.minWaitTime + _random.nextInt(delayRange);

    _stimulusTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted && !_gameEnded) {
        setState(() {
          _showStimulus = true;
          _stimulusStartTime = DateTime.now();
        });
      }
    });
  }

  void _handleTap() {
    if (_gameEnded) return;

    if (!_showStimulus) {
      // False start
      AudioService.playIncorrect();
      setState(() {
        _waitingForTap = true;
      });

      _falseStarts.add(true);
      _reactionTimes.add(0);
      _totalScore += ScoringEngine.calculateSpeedTapScore(0, true);

      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _currentTrial++;
          _startNextTrial();
        }
      });
    } else {
      // Valid tap
      AudioService.playCorrect();
      final reactionTime =
          DateTime.now().difference(_stimulusStartTime!).inMilliseconds;

      _falseStarts.add(false);
      _reactionTimes.add(reactionTime);
      _totalScore += ScoringEngine.calculateSpeedTapScore(reactionTime, false);

      _currentTrial++;
      _startNextTrial();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _stimulusTimer?.cancel();

    AudioService.playGameComplete();

    setState(() {
      _gameEnded = true;
    });

    // Record result
    final accuracy = _falseStarts.where((fs) => !fs).length / _totalTrials;
    final avgReactionTime = _reactionTimes.isNotEmpty
        ? _reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length
        : 0.0;

    // For Speed Tap, use reaction time as the score (lower is better)
    // We'll invert it so that lower reaction times give higher scores for the rating system
    final reactionTimeScore = avgReactionTime > 0
        ? (1000 - avgReactionTime).clamp(0, 1000).toDouble()
        : 0.0;

    final result = SessionResult(
      sessionId:
          ref.read(sessionProvider).currentSessionId ?? const Uuid().v4(),
      gameId: widget.gameId,
      score: reactionTimeScore, // Use reaction time-based score
      accuracy: accuracy,
      timestamp: DateTime.now(),
      reactionTime: avgReactionTime,
    );

    ref.read(sessionProvider.notifier).recordGameResult(result);
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  (String, String) _getCongratulationsMessage(
      double avgReactionTime, double accuracy) {
    // For Speed Tap, focus on reaction time (lower is better)
    if (avgReactionTime <= 200 && accuracy >= 0.9) {
      return (
        'Lightning Fast! ⚡',
        'Incredible reflexes! You\'re a speed demon!'
      );
    } else if (avgReactionTime <= 250 && accuracy >= 0.8) {
      return (
        'Super Quick! 🚀',
        'Amazing speed! Your reflexes are outstanding!'
      );
    } else if (avgReactionTime <= 300 && accuracy >= 0.7) {
      return (
        'Great Reflexes! 🎯',
        'Excellent reaction time! You\'re getting faster!'
      );
    } else if (avgReactionTime <= 400 && accuracy >= 0.6) {
      return (
        'Good Speed! 👍',
        'Nice reflexes! Keep practicing to get even faster!'
      );
    } else if (accuracy >= 0.8) {
      return (
        'Accurate Tapper! 🎯',
        'Great accuracy! Focus on speed for even better results!'
      );
    } else {
      return (
        'Keep Practicing! 💪',
        'Your reflexes will improve with practice! Stay focused!'
      );
    }
  }
}
