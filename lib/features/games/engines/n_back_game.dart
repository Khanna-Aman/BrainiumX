import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class NBackGame extends ConsumerStatefulWidget {
  final GameId gameId;

  const NBackGame({super.key, required this.gameId});

  @override
  ConsumerState<NBackGame> createState() => _NBackGameState();
}

class _NBackGameState extends ConsumerState<NBackGame> {
  late Random _random;
  Timer? _gameTimer;
  Timer? _stimulusTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;
  bool _showingStimulus = false;
  bool _canRespond = false;

  int _currentTick = 0;
  int _totalTicks = 30;
  int _timeLimit = 90;
  int _remainingTime = 90;
  int _nLevel = 2; // 2-back

  List<int> _sequence = [];
  List<bool> _responses = [];
  List<bool> _correctAnswers = [];
  double _totalScore = 0;

  int _currentPosition = -1;

  @override
  void initState() {
    super.initState();
    _random = Random();
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
          const Icon(Icons.memory, size: 64, color: Colors.purple),
          const SizedBox(height: 24),
          Text(
            'N-Back ($_nLevel-Back)',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            '• Watch the positions on the grid\n'
            '• Tap MATCH if the current position is the same\n'
            '  as the position $_nLevel steps back\n'
            '• Tap NO MATCH if it\'s different\n'
            '• Stay focused and remember the sequence!',
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16),
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
              Text('Tick: ${_currentTick + 1}/$_totalTicks',
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
              // 3x3 Grid
              Container(
                width: 300,
                height: 300,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final isActive =
                        _showingStimulus && index == _currentPosition;

                    return Container(
                      decoration: BoxDecoration(
                        color: isActive ? Colors.blue : Colors.grey[300],
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              if (_canRespond)
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
                      child:
                          const Text('MATCH', style: TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: () => _handleResponse(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text('NO MATCH',
                          style: TextStyle(fontSize: 18)),
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
    final hits = _responses
        .asMap()
        .entries
        .where((entry) => _correctAnswers[entry.key] && entry.value)
        .length;
    final misses = _correctAnswers.where((c) => c).length - hits;
    final falseAlarms = _responses
        .asMap()
        .entries
        .where((entry) => !_correctAnswers[entry.key] && entry.value)
        .length;
    final accuracy = _responses
            .asMap()
            .entries
            .where((entry) => _correctAnswers[entry.key] == entry.value)
            .length /
        _totalTicks;

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
                  _ResultRow('Hits', hits.toString()),
                  _ResultRow('Misses', misses.toString()),
                  _ResultRow('False Alarms', falseAlarms.toString()),
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

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0 || _currentTick >= _totalTicks) {
        _endGame();
      }
    });

    _nextTick();
  }

  void _nextTick() {
    if (_currentTick >= _totalTicks) {
      _endGame();
      return;
    }

    // Generate next position
    _currentPosition = _random.nextInt(9);
    _sequence.add(_currentPosition);

    // Determine if this is a match
    bool isMatch = false;
    if (_sequence.length > _nLevel) {
      isMatch = _sequence[_sequence.length - 1] ==
          _sequence[_sequence.length - 1 - _nLevel];
    }
    _correctAnswers.add(isMatch);

    setState(() {
      _showingStimulus = true;
      _canRespond = false;
    });

    // Show stimulus for 500ms
    _stimulusTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _showingStimulus = false;
        _canRespond = true;
      });

      // Allow response for 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (_responses.length <= _currentTick) {
          _responses.add(false); // No response = false
        }
        _currentTick++;
        _nextTick();
      });
    });
  }

  void _handleResponse(bool response) {
    if (_responses.length <= _currentTick) {
      _responses.add(response);

      final correct = _correctAnswers[_currentTick];
      final hit = correct && response;
      final miss = correct && !response;
      final falseAlarm = !correct && response;

      if (hit) {
        _totalScore += ScoringEngine.calculateNBackScore(true, false, false);
      } else if (miss) {
        _totalScore += ScoringEngine.calculateNBackScore(false, true, false);
      } else if (falseAlarm) {
        _totalScore += ScoringEngine.calculateNBackScore(false, false, true);
      }

      setState(() {
        _canRespond = false;
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _stimulusTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    // Record result
    final accuracy = _responses
            .asMap()
            .entries
            .where((entry) => _correctAnswers[entry.key] == entry.value)
            .length /
        _totalTicks;

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
