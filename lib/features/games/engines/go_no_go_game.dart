import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/utils/object_pool.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';

class GoNoGoGame extends BaseGame {
  const GoNoGoGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<GoNoGoGame> createState() => _GoNoGoGameState();
}

class _GoNoGoGameState extends BaseGameState<GoNoGoGame> {
  late Random _random;
  Timer? _stimulusTimer;

  bool _showingStimulus = false;
  bool _canRespond = false;

  int _currentTick = 0;
  List<bool> _responses = [];
  List<bool> _targets = [];

  String _currentStimulus = '';
  bool _isTarget = false;

  final String _targetStimulus = '●';
  final String _noGoStimulus = '■';

  @override
  void initState() {
    super.initState();
    _random = Random();
    _responses = BoolPool.getResponseList();
    _targets = BoolPool.getResponseList();
  }

  @override
  void dispose() {
    _stimulusTimer?.cancel();
    BoolPool.releaseResponseList(_responses);
    BoolPool.releaseResponseList(_targets);
    super.dispose();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getGoNoGoConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _nextTrial();
  }

  @override
  void onGamePaused() {
    _stimulusTimer?.cancel();
  }

  @override
  void onGameResumed() {
    if (_showingStimulus) {
      _nextTrial();
    }
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

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_arrow, size: 64, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            'Go/No-Go',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(_targetStimulus,
                      style:
                          const TextStyle(fontSize: 48, color: Colors.green)),
                  const Text('TAP!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              Column(
                children: [
                  Text(_noGoStimulus,
                      style: const TextStyle(fontSize: 48, color: Colors.red)),
                  const Text('DON\'T TAP!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '• Tap when you see the circle (●)\n'
            '• DON\'T tap when you see the square (■)\n'
            '• React quickly but avoid false alarms\n'
            '• Tests impulse control and attention',
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
                    'Trial: ${_currentTick + 1}/$totalRounds',
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Time: $remainingTime s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Score: ${totalScore.toInt()}',
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final deviceType = ResponsiveUtils.getDeviceType(context);
                  final spacing = ResponsiveUtils.getSpacing(context);

                  return GestureDetector(
                    onTap: _handleTap,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(spacing),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _showingStimulus
                            ? Text(
                                _currentStimulus,
                                style: TextStyle(
                                  fontSize: switch (deviceType) {
                                        DeviceType.mobile => 100.0,
                                        DeviceType.tablet => 140.0,
                                        DeviceType.desktop => 180.0,
                                      } *
                                      ResponsiveUtils.getFontScale(context),
                                  color: _isTarget ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                '+',
                                style: TextStyle(
                                  fontSize: switch (deviceType) {
                                        DeviceType.mobile => 40.0,
                                        DeviceType.tablet => 50.0,
                                        DeviceType.desktop => 60.0,
                                      } *
                                      ResponsiveUtils.getFontScale(context),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Instructions reminder
          Container(
            padding: ResponsiveUtils.getScreenPadding(context).copyWith(top: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context,
                        type: SpacingType.small)),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _targetStimulus,
                          style: TextStyle(
                            fontSize:
                                24 * ResponsiveUtils.getFontScale(context),
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveUtils.getSpacing(context,
                                type: SpacingType.xs)),
                        Text(
                          'TAP',
                          style: TextStyle(
                            fontSize:
                                14 * ResponsiveUtils.getFontScale(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    width: ResponsiveUtils.getSpacing(context,
                        type: SpacingType.small)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context,
                        type: SpacingType.small)),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _noGoStimulus,
                          style: TextStyle(
                            fontSize:
                                24 * ResponsiveUtils.getFontScale(context),
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveUtils.getSpacing(context,
                                type: SpacingType.xs)),
                        Text(
                          'DON\'T TAP',
                          style: TextStyle(
                            fontSize:
                                14 * ResponsiveUtils.getFontScale(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final hits = _responses
        .asMap()
        .entries
        .where((entry) => _targets[entry.key] && entry.value)
        .length;
    final falseAlarms = _responses
        .asMap()
        .entries
        .where((entry) => !_targets[entry.key] && entry.value)
        .length;
    final correctRejections = _responses
        .asMap()
        .entries
        .where((entry) => !_targets[entry.key] && !entry.value)
        .length;
    final accuracy = (hits + correctRejections) / totalRounds;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 24),
          Text(
            'Game Complete!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _resultRow('Score', totalScore.toInt().toString()),
                  _resultRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                  _resultRow('Hits', hits.toString()),
                  _resultRow('False Alarms', falseAlarms.toString()),
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

  void _nextTrial() {
    if (_currentTick >= totalRounds) {
      _endGame();
      return;
    }

    // 70% targets, 30% no-go (using GameConstants)
    _isTarget = _random.nextDouble() < GameConstants.targetProbability;
    _currentStimulus = _isTarget ? _targetStimulus : _noGoStimulus;
    _targets.add(_isTarget);

    setState(() {
      _showingStimulus = true;
      _canRespond = true;
    });

    // Show stimulus for configured time
    _stimulusTimer = addTimer(GameConstants.stimulusDisplayTime, () {
      if (mounted) {
        setState(() {
          _showingStimulus = false;
          _canRespond = false;
        });

        // If no response recorded, add false
        if (_responses.length <= _currentTick) {
          _responses.add(false);
        }

        _currentTick++;

        // Wait before next trial
        addTimer(GameConstants.interTrialInterval, () {
          if (mounted) _nextTrial();
        });
      }
    });
  }

  void _handleTap() {
    if (!_canRespond || _responses.length > _currentTick) return;

    _responses.add(true);

    final hit = _isTarget;
    final falseAlarm = !_isTarget;

    final score = ScoringEngine.calculateGoNoGoScore(hit, falseAlarm);
    addScore(score.toInt());

    setState(() {
      _canRespond = false;
    });
  }

  void _endGame() {
    // Call BaseGame's endGame method
    endGame();
  }

  @override
  void onGameEnded() {
    _stimulusTimer?.cancel();

    final hits = _responses
        .asMap()
        .entries
        .where((entry) => _targets[entry.key] && entry.value)
        .length;
    final correctRejections = _responses
        .asMap()
        .entries
        .where((entry) => !_targets[entry.key] && !entry.value)
        .length;
    final accuracy = (hits + correctRejections) / totalRounds;

    // Record the session result using BaseGame's method
    recordSessionResult(accuracy: accuracy);
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
}
