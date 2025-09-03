import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class TrailConnectGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final dynamic difficulty;

  const TrailConnectGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<TrailConnectGame> createState() => _TrailConnectGameState();
}

class _TrailConnectGameState extends ConsumerState<TrailConnectGame> {
  late Random _random;
  Timer? _gameTimer;
  Stopwatch? _trialStopwatch;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentBoard = 0;
  int _totalBoards = 5;
  int _timeLimit = 150;
  int _remainingTime = 150;

  List<int> _trialTimes = [];
  List<int> _errors = [];
  double _totalScore = 0;

  List<TrailNode> _nodes = [];
  List<int> _sequence = [];
  int _currentTarget = 0;
  int _errorCount = 0;

  @override
  void initState() {
    super.initState();
    _random = Random();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _trialStopwatch?.stop();
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
    return Column(
      children: [
        // HUD
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Board: ${_currentBoard + 1}/$_totalBoards',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Time: $_remainingTime s',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Target: ${_currentTarget + 1}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Game Area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Stack(
              children: _nodes
                  .map((node) => Positioned(
                        left: node.x,
                        top: node.y,
                        child: GestureDetector(
                          onTap: () => _handleNodeTap(node.number),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: node.number == _sequence[_currentTarget]
                                  ? Colors.green
                                  : node.number < _sequence[_currentTarget]
                                      ? Colors.grey
                                      : Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${node.number}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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

        // Error feedback
        if (_errorCount > 0)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red[100],
            child: Text(
              'Errors this board: $_errorCount',
              style: const TextStyle(
                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
      ],
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
                  _ResultRow('Score', _totalScore.toInt().toString()),
                  _ResultRow('Avg Time', '${avgTime.toStringAsFixed(1)}s'),
                  _ResultRow('Total Errors', totalErrors.toString()),
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

    _startBoard();
  }

  void _startBoard() {
    _nodes.clear();
    _sequence = List.generate(
        8 + _currentBoard * 2, (i) => i + 1); // Increasing difficulty
    _currentTarget = 0;
    _errorCount = 0;

    // Generate random positions for nodes
    final screenWidth = 300.0;
    final screenHeight = 400.0;

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
        _totalScore += ScoringEngine.calculateTrailConnectScore(
            parTime, time, _errorCount);

        _currentBoard++;

        if (_currentBoard >= _totalBoards) {
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
    _gameTimer?.cancel();
    _trialStopwatch?.stop();

    setState(() {
      _gameEnded = true;
    });

    final avgTime = _trialTimes.isNotEmpty
        ? _trialTimes.reduce((a, b) => a + b) / _trialTimes.length / 1000
        : 0.0;
    final accuracy = _errors.isEmpty
        ? 1.0
        : 1.0 -
            (_errors.reduce((a, b) => a + b) /
                (_sequence.length * _currentBoard));

    final result = SessionResult(
      sessionId:
          ref.read(sessionProvider).currentSessionId ?? const Uuid().v4(),
      gameId: widget.gameId,
      score: _totalScore,
      accuracy: accuracy.clamp(0.0, 1.0),
      timestamp: DateTime.now(),
      reactionTime: avgTime,
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

class TrailNode {
  final int number;
  final double x;
  final double y;

  TrailNode({required this.number, required this.x, required this.y});
}
