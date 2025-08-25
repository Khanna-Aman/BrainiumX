import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class VisualSearchGame extends ConsumerStatefulWidget {
  final GameId gameId;

  const VisualSearchGame({super.key, required this.gameId});

  @override
  ConsumerState<VisualSearchGame> createState() => _VisualSearchGameState();
}

class _VisualSearchGameState extends ConsumerState<VisualSearchGame> {
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentBoard = 0;
  int _totalBoards = 8;
  int _timeLimit = 120;
  int _remainingTime = 120;

  List<int> _scores = [];
  double _totalScore = 0;

  List<VisualItem> _items = [];
  String _targetShape = '';
  Color _targetColor = Colors.red;
  int _targetsFound = 0;
  int _totalTargets = 0;
  int _wrongTaps = 0;

  final List<String> _shapes = ['●', '■', '▲', '◆'];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange
  ];

  @override
  void initState() {
    super.initState();
    _random = Random();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
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
          const Icon(Icons.visibility, size: 64, color: Colors.indigo),
          const SizedBox(height: 24),
          Text(
            'Visual Search',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Find and tap ALL targets shown at the top\n'
            '• Targets have specific shape AND color\n'
            '• Avoid tapping wrong items (penalty!)\n'
            '• Work quickly through multiple boards\n'
            '• Tests visual attention and processing speed',
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
    return Column(
      children: [
        // HUD
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Board: ${_currentBoard + 1}/$_totalBoards',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Time: $_remainingTime s',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Score: ${_totalScore.toInt()}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Find: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_targetShape,
                      style: TextStyle(fontSize: 24, color: _targetColor)),
                  const SizedBox(width: 16),
                  Text('Found: $_targetsFound/$_totalTargets',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),

        // Game Area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: _items
                  .map((item) => Positioned(
                        left: item.x,
                        top: item.y,
                        child: GestureDetector(
                          onTap: () => _handleItemTap(item),
                          child: Container(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: Text(
                                item.shape,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: item.found ? Colors.grey : item.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),

        // Progress
        if (_targetsFound == _totalTargets)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Board Complete!',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _nextBoard,
                  child: const Text('Next Board'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResults() {
    final avgScore = _scores.isNotEmpty
        ? _scores.reduce((a, b) => a + b) / _scores.length
        : 0;

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
                  _ResultRow('Total Score', _totalScore.toInt().toString()),
                  _ResultRow('Avg Board Score', avgScore.toInt().toString()),
                  _ResultRow('Boards Completed', '$_currentBoard'),
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
    setState(() {
      _gameStarted = true;
      _remainingTime = _timeLimit;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0 || _currentBoard >= _totalBoards) {
        _endGame();
      }
    });

    _generateBoard();
  }

  void _generateBoard() {
    _items.clear();
    _targetsFound = 0;
    _wrongTaps = 0;

    // Choose target
    _targetShape = _shapes[_random.nextInt(_shapes.length)];
    _targetColor = _colors[_random.nextInt(_colors.length)];

    // Generate items
    final numItems = 20 + _currentBoard * 5; // Increasing difficulty
    _totalTargets = 3 + _random.nextInt(3); // 3-5 targets

    // Add targets
    for (int i = 0; i < _totalTargets; i++) {
      _items.add(VisualItem(
        shape: _targetShape,
        color: _targetColor,
        x: _random.nextDouble() * 300,
        y: _random.nextDouble() * 400,
        isTarget: true,
      ));
    }

    // Add distractors
    for (int i = _totalTargets; i < numItems; i++) {
      String shape;
      Color color;

      // Make sure it's not a target
      do {
        shape = _shapes[_random.nextInt(_shapes.length)];
        color = _colors[_random.nextInt(_colors.length)];
      } while (shape == _targetShape && color == _targetColor);

      _items.add(VisualItem(
        shape: shape,
        color: color,
        x: _random.nextDouble() * 300,
        y: _random.nextDouble() * 400,
        isTarget: false,
      ));
    }

    setState(() {});
  }

  void _handleItemTap(VisualItem item) {
    if (item.found) return;

    if (item.isTarget) {
      item.found = true;
      _targetsFound++;
      _totalScore += ScoringEngine.calculateVisualSearchScore(true, true);
    } else {
      _wrongTaps++;
      _totalScore += ScoringEngine.calculateVisualSearchScore(false, false);
    }

    setState(() {});
  }

  void _nextBoard() {
    final boardScore = (_targetsFound * 40) - (_wrongTaps * 50);
    _scores.add(boardScore);

    _currentBoard++;

    if (_currentBoard >= _totalBoards) {
      _endGame();
    } else {
      _generateBoard();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    final accuracy = _scores.isNotEmpty
        ? _scores.where((s) => s > 0).length / _scores.length
        : 0.0;

    final result = SessionResult(
      sessionId:
          ref.read(sessionProvider).currentSessionId ?? const Uuid().v4(),
      gameId: widget.gameId,
      score: _totalScore,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );

    ref.read(sessionProvider.notifier).recordGameResult(result);
  }

  Widget _ResultRow(String label, String value) {
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

class VisualItem {
  final String shape;
  final Color color;
  final double x;
  final double y;
  final bool isTarget;
  bool found;

  VisualItem({
    required this.shape,
    required this.color,
    required this.x,
    required this.y,
    required this.isTarget,
    this.found = false,
  });
}
