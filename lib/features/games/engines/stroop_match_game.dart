import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/services/audio_service.dart';

class StroopMatchGame extends ConsumerStatefulWidget {
  final GameId gameId;

  const StroopMatchGame({super.key, required this.gameId});

  @override
  ConsumerState<StroopMatchGame> createState() => _StroopMatchGameState();
}

class _StroopMatchGameState extends ConsumerState<StroopMatchGame> {
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentTrial = 0;
  int _totalTrials = 15;
  int _timeLimit = 90;
  int _remainingTime = 90;

  List<bool> _responses = [];
  double _totalScore = 0;

  String _currentWord = '';
  Color _currentColor = Colors.red;
  bool _isCongruent = true;

  final List<String> _colorWords = ['RED', 'BLUE', 'GREEN', 'YELLOW'];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
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
          const Icon(Icons.psychology, size: 64, color: Colors.purple),
          const SizedBox(height: 24),
          Text(
            'Stroop Match',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• You will see color words (RED, BLUE, etc.)\n'
            '• The word color may match or not match the text\n'
            '• Tap MATCH if the word and color are the same\n'
            '• Tap NO MATCH if they are different\n'
            '• Ignore the word meaning, focus on the color!',
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
              Text('Trial: ${_currentTrial + 1}/$_totalTrials',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'What color is this word?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Text(
                _currentWord,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: _currentColor,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleResponse(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('MATCH', style: TextStyle(fontSize: 18)),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleResponse(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child:
                        const Text('NO MATCH', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / _totalTrials;

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

    _generateStimulus();
  }

  void _generateStimulus() {
    final wordIndex = _random.nextInt(_colorWords.length);
    final colorIndex = _random.nextInt(_colors.length);

    setState(() {
      _currentWord = _colorWords[wordIndex];
      _currentColor = _colors[colorIndex];
      _isCongruent = wordIndex == colorIndex;
    });
  }

  void _handleResponse(bool userSaysMatch) {
    final correct = userSaysMatch == _isCongruent;

    if (correct) {
      AudioService.playCorrect();
    } else {
      AudioService.playIncorrect();
    }

    _responses.add(correct);
    _totalScore += ScoringEngine.calculateStroopScore(correct);

    _currentTrial++;

    if (_currentTrial >= _totalTrials) {
      _endGame();
    } else {
      _generateStimulus();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();

    AudioService.playGameComplete();

    setState(() {
      _gameEnded = true;
    });

    // Record result
    final accuracy = _responses.where((r) => r).length / _totalTrials;

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
