import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class PatternMatrixGame extends ConsumerStatefulWidget {
  final GameId gameId;

  const PatternMatrixGame({super.key, required this.gameId});

  @override
  ConsumerState<PatternMatrixGame> createState() => _PatternMatrixGameState();
}

class _PatternMatrixGameState extends ConsumerState<PatternMatrixGame> {
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentPuzzle = 0;
  int _totalPuzzles = 12;
  int _timeLimit = 180;
  int _remainingTime = 180;

  List<bool> _responses = [];
  double _totalScore = 0;

  List<List<String>> _matrix = [];
  List<String> _options = [];
  int _correctOption = 0;

  final List<String> _patterns = ['●', '■', '▲', '◆', '★'];

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
          const Icon(Icons.grid_3x3, size: 64, color: Colors.purple),
          const SizedBox(height: 24),
          Text(
            'Pattern Matrix',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Look at the 3×3 pattern matrix\n'
            '• One piece is missing (shown as ?)\n'
            '• Find the pattern and choose the correct piece\n'
            '• Use logical reasoning to solve each puzzle\n'
            '• Tests abstract reasoning skills',
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
              Text('Puzzle: ${_currentPuzzle + 1}/$_totalPuzzles',
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
        ),

        // Game Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Complete the pattern:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Matrix
                Container(
                  width: 240,
                  height: 240,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      final content = _matrix[row][col];

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color:
                              content == '?' ? Colors.grey[300] : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            content,
                            style: TextStyle(
                              fontSize: content == '?' ? 32 : 40,
                              fontWeight: FontWeight.bold,
                              color:
                                  content == '?' ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Choose the missing piece:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;

                    return GestureDetector(
                      onTap: () => _handleAnswer(index),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / _totalPuzzles;

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
                  _ResultRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                  _ResultRow('Puzzles Completed', '$_currentPuzzle'),
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

      if (_remainingTime <= 0 || _currentPuzzle >= _totalPuzzles) {
        _endGame();
      }
    });

    _generatePuzzle();
  }

  void _generatePuzzle() {
    // Create a simple pattern (alternating or sequential)
    _matrix = List.generate(3, (i) => List.generate(3, (j) => ''));

    // Simple alternating pattern
    final pattern1 = _patterns[_random.nextInt(_patterns.length)];
    final pattern2 = _patterns[_random.nextInt(_patterns.length)];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((i + j) % 2 == 0) {
          _matrix[i][j] = pattern1;
        } else {
          _matrix[i][j] = pattern2;
        }
      }
    }

    // Remove one piece (not center for simplicity)
    final missingRow = _random.nextInt(3);
    final missingCol = _random.nextInt(3);
    final correctAnswer = _matrix[missingRow][missingCol];
    _matrix[missingRow][missingCol] = '?';

    // Generate options
    _options = [correctAnswer];
    while (_options.length < 4) {
      final wrongOption = _patterns[_random.nextInt(_patterns.length)];
      if (!_options.contains(wrongOption)) {
        _options.add(wrongOption);
      }
    }

    _options.shuffle(_random);
    _correctOption = _options.indexOf(correctAnswer);

    setState(() {});
  }

  void _handleAnswer(int selectedOption) {
    final correct = selectedOption == _correctOption;
    _responses.add(correct);
    _totalScore += ScoringEngine.calculatePatternMatrixScore(correct);

    _currentPuzzle++;

    if (_currentPuzzle >= _totalPuzzles) {
      _endGame();
    } else {
      _generatePuzzle();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    final accuracy = _responses.where((r) => r).length / _totalPuzzles;

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
