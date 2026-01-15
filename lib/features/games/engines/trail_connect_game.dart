import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/utils/object_pool.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/base/base_game.dart';

class TrailConnectGame extends BaseGame {
  const TrailConnectGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<TrailConnectGame> createState() => _TrailConnectGameState();
}

class _TrailConnectGameState extends BaseGameState<TrailConnectGame> {
  late Random _random;
  Stopwatch? _trialStopwatch;

  int _currentBoard = 0;

  List<int> _trialTimes = [];
  List<int> _errors = [];

  final List<TrailNode> _nodes = [];
  List<int> _sequence = [];
  int _currentTarget = 0;
  int _errorCount = 0;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _trialTimes = IntPool.getIntList();
    _errors = IntPool.getIntList();
    _sequence = IntPool.getIntList();
  }

  @override
  void dispose() {
    _trialStopwatch?.stop();
    IntPool.releaseIntList(_trialTimes);
    IntPool.releaseIntList(_errors);
    IntPool.releaseIntList(_sequence);
    super.dispose();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getTrailConnectConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _startBoard();
  }

  @override
  void onGamePaused() {
    _trialStopwatch?.stop();
  }

  @override
  void onGameResumed() {
    _trialStopwatch?.start();
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
          const Icon(Icons.timeline, size: 64, color: Colors.teal),
          const SizedBox(height: 24),
          Text(
            'Trail Connect',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Connect the numbers in order: 1 → 2 → 3 → 4...\n'
            '• Tap each number in sequence as fast as possible\n'
            '• Avoid mistakes - they cost time!\n'
            '• Complete 5 boards as quickly as you can\n'
            '• Tests attention and processing speed',
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
                    'Board: ${_currentBoard + 1}/$totalRounds',
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
                    'Target: ${_currentTarget + 1}',
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
              padding:
                  ResponsiveUtils.getScreenPadding(context).copyWith(top: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final deviceType = ResponsiveUtils.getDeviceType(context);
                  final spacing = ResponsiveUtils.getSpacing(context);

                  // Responsive node size
                  final nodeSize = switch (deviceType) {
                    DeviceType.mobile => 45.0,
                    DeviceType.tablet => 55.0,
                    DeviceType.desktop => 65.0,
                  };

                  // Calculate available area for nodes
                  final availableWidth = constraints.maxWidth - spacing * 2;
                  final availableHeight = constraints.maxHeight - spacing * 2;

                  return Container(
                    margin: EdgeInsets.all(spacing),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        children: _nodes.map((node) {
                          // Scale node positions to fit available area
                          final scaledX =
                              (node.x / 300) * (availableWidth - nodeSize);
                          final scaledY =
                              (node.y / 300) * (availableHeight - nodeSize);

                          return Positioned(
                            left: scaledX,
                            top: scaledY,
                            child: GestureDetector(
                              onTap: () => _handleNodeTap(node.number),
                              child: Container(
                                width: nodeSize,
                                height: nodeSize,
                                decoration: BoxDecoration(
                                  color: node.number ==
                                          _sequence[_currentTarget]
                                      ? Colors.green
                                      : node.number < _sequence[_currentTarget]
                                          ? Colors.grey
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${node.number}',
                                    style: TextStyle(
                                      fontSize: switch (deviceType) {
                                            DeviceType.mobile => 16.0,
                                            DeviceType.tablet => 18.0,
                                            DeviceType.desktop => 20.0,
                                          } *
                                          ResponsiveUtils.getFontScale(context),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Error feedback
          if (_errorCount > 0)
            Container(
              padding: EdgeInsets.all(
                  ResponsiveUtils.getSpacing(context, type: SpacingType.small)),
              margin:
                  ResponsiveUtils.getScreenPadding(context).copyWith(top: 0),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: Text(
                'Errors this board: $_errorCount',
                style: TextStyle(
                  fontSize: 16 * ResponsiveUtils.getFontScale(context),
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final avgTime = _trialTimes.isNotEmpty
        ? _trialTimes.reduce((a, b) => a + b) / _trialTimes.length / 1000
        : 0.0;
    final totalErrors = _errors.reduce((a, b) => a + b);

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
                  _resultRow('Avg Time', '${avgTime.toStringAsFixed(1)}s'),
                  _resultRow('Total Errors', totalErrors.toString()),
                  _resultRow('Boards Completed', '$_currentBoard'),
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

  void _startBoard() {
    _nodes.clear();
    _sequence = List.generate(
        8 + _currentBoard * 2, (i) => i + 1); // Increasing difficulty
    _currentTarget = 0;
    _errorCount = 0;

    // Generate random positions for nodes
    const screenWidth = 300.0;
    const screenHeight = 400.0;

    for (int i = 0; i < _sequence.length; i++) {
      bool validPosition = false;
      double x = 0, y = 0;

      while (!validPosition) {
        x = _random.nextDouble() * (screenWidth - 50);
        y = _random.nextDouble() * (screenHeight - 50);

        validPosition = _nodes.every(
            (node) => (node.x - x).abs() > 60 || (node.y - y).abs() > 60);
      }

      _nodes.add(TrailNode(number: _sequence[i], x: x, y: y));
    }

    _trialStopwatch = Stopwatch()..start();
    setState(() {});
  }

  void _handleNodeTap(int number) {
    if (number == _sequence[_currentTarget]) {
      // Correct tap
      _currentTarget++;

      if (_currentTarget >= _sequence.length) {
        // Board complete
        _trialStopwatch?.stop();
        final time = _trialStopwatch?.elapsedMilliseconds ?? 0;
        _trialTimes.add(time);
        _errors.add(_errorCount);

        final parTime = 15000 + _currentBoard * 5000; // Expected time
        final score = ScoringEngine.calculateTrailConnectScore(
            parTime, time, _errorCount);
        addScore(score.toInt());

        _currentBoard++;

        if (_currentBoard >= totalRounds) {
          _endGame();
        } else {
          _startBoard();
        }
      }
    } else {
      // Wrong tap
      _errorCount++;
    }

    setState(() {});
  }

  void _endGame() {
    endGame();
  }

  @override
  void onGameEnded() {
    _trialStopwatch?.stop();

    final avgTime = _trialTimes.isNotEmpty
        ? _trialTimes.reduce((a, b) => a + b) / _trialTimes.length / 1000
        : 0.0;
    final accuracy = _errors.isEmpty
        ? 1.0
        : 1.0 -
            (_errors.reduce((a, b) => a + b) /
                (_sequence.length * _currentBoard));

    recordSessionResult(
      accuracy: accuracy.clamp(0.0, 1.0),
      reactionTime: avgTime,
    );
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

class TrailNode {
  final int number;
  final double x;
  final double y;

  TrailNode({required this.number, required this.x, required this.y});
}
