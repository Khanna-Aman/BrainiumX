import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class ArithmeticSprintGame extends ConsumerStatefulWidget {
  final GameId gameId;

  const ArithmeticSprintGame({super.key, required this.gameId});

  @override
  ConsumerState<ArithmeticSprintGame> createState() =>
      _ArithmeticSprintGameState();
}

class _ArithmeticSprintGameState extends ConsumerState<ArithmeticSprintGame> {
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentQuestion = 0;
  int _totalQuestions = 20;
  int _timeLimit = 120;
  int _remainingTime = 120;

  List<bool> _responses = [];
  double _totalScore = 0;

  String _equation = '';
  int _correctAnswer = 0;
  List<int> _options = [];

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
          const Icon(Icons.calculate, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          Text(
            'Arithmetic Sprint',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Solve math problems as quickly as possible\n'
            '• Choose the correct answer from 4 options\n'
            '• Problems include +, -, ×, ÷\n'
            '• Work fast but stay accurate\n'
            '• Tests mental arithmetic speed',
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
              Text('Question: ${_currentQuestion + 1}/$_totalQuestions',
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _equation,
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 60),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      onPressed: () => _handleAnswer(_options[index]),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      child: Text('${_options[index]}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / _totalQuestions;

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
                  _resultRow('Score', _totalScore.toInt().toString()),
                  _resultRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                  _resultRow('Questions Completed', '$_currentQuestion'),
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

      if (_remainingTime <= 0 || _currentQuestion >= _totalQuestions) {
        _endGame();
      }
    });

    _generateQuestion();
  }

  void _generateQuestion() {
    final operations = ['+', '-', '×', '÷'];
    final operation = operations[_random.nextInt(operations.length)];

    int a, b;

    switch (operation) {
      case '+':
        a = 10 + _random.nextInt(90);
        b = 10 + _random.nextInt(90);
        _correctAnswer = a + b;
        break;
      case '-':
        a = 50 + _random.nextInt(50);
        b = 10 + _random.nextInt(40);
        _correctAnswer = a - b;
        break;
      case '×':
        a = 2 + _random.nextInt(12);
        b = 2 + _random.nextInt(12);
        _correctAnswer = a * b;
        break;
      case '÷':
        _correctAnswer = 2 + _random.nextInt(12);
        b = 2 + _random.nextInt(12);
        a = _correctAnswer * b;
        break;
      default:
        a = 10;
        b = 5;
        _correctAnswer = 15;
    }

    _equation = '$a $operation $b = ?';

    // Generate options
    _options = [_correctAnswer];
    while (_options.length < 4) {
      int wrongAnswer;
      if (operation == '÷') {
        wrongAnswer = _correctAnswer + _random.nextInt(10) - 5;
      } else {
        wrongAnswer = _correctAnswer + _random.nextInt(20) - 10;
      }

      if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }

    _options.shuffle(_random);
    setState(() {});
  }

  void _handleAnswer(int answer) {
    final correct = answer == _correctAnswer;
    _responses.add(correct);
    _totalScore += ScoringEngine.calculateArithmeticScore(correct);

    _currentQuestion++;

    if (_currentQuestion >= _totalQuestions) {
      _endGame();
    } else {
      _generateQuestion();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    final accuracy = _responses.where((r) => r).length / _totalQuestions;

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
