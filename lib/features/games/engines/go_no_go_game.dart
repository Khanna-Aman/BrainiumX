import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class GoNoGoGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final dynamic difficulty;

  const GoNoGoGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<GoNoGoGame> createState() => _GoNoGoGameState();
}

class _GoNoGoGameState extends ConsumerState<GoNoGoGame> {
  late Random _random;
  Timer? _gameTimer;
  Timer? _stimulusTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;
  bool _showingStimulus = false;
  bool _canRespond = false;

  int _currentTick = 0;
  int _totalTicks = 50;
  int _timeLimit = 120;
  int _remainingTime = 120;

  List<bool> _responses = [];
  List<bool> _targets = [];
  double _totalScore = 0;

  String _currentStimulus = '';
  bool _isTarget = false;

  final String _targetStimulus = '●';
  final String _noGoStimulus = '■';

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
    return Column(
      children: [
        // HUD
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trial: ${_currentTick + 1}/$_totalTicks',
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
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Center(
                child: _showingStimulus
                    ? Text(
                        _currentStimulus,
                        style: TextStyle(
                          fontSize: 120,
                          color: _isTarget ? Colors.green : Colors.red,
                        ),
                      )
                    : const Text(
                        '+',
                        style: TextStyle(fontSize: 48, color: Colors.grey),
                      ),
              ),
            ),
          ),
        ),

        // Instructions reminder
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Text(_targetStimulus,
                      style:
                          const TextStyle(fontSize: 24, color: Colors.green)),
                  const SizedBox(width: 8),
                  const Text('TAP',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text(_noGoStimulus,
                      style: const TextStyle(fontSize: 24, color: Colors.red)),
                  const SizedBox(width: 8),
                  const Text('DON\'T TAP',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
    final accuracy = (hits + correctRejections) / _totalTicks;

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
    setState(() {
      _gameStarted = true;
      _remainingTime = _timeLimit;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0 || _currentTick >= _totalTicks) {
        _endGame();
      }
    });

    _nextTrial();
  }

  void _nextTrial() {
    if (_currentTick >= _totalTicks) {
      _endGame();
      return;
    }

    // 70% targets, 30% no-go
    _isTarget = _random.nextDouble() < 0.7;
    _currentStimulus = _isTarget ? _targetStimulus : _noGoStimulus;
    _targets.add(_isTarget);

    setState(() {
      _showingStimulus = true;
      _canRespond = true;
    });

    // Show stimulus for 1 second
    _stimulusTimer = Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _showingStimulus = false;
        _canRespond = false;
      });

      // If no response recorded, add false
      if (_responses.length <= _currentTick) {
        _responses.add(false);
      }

      _currentTick++;

      // Wait 500ms before next trial
      Timer(const Duration(milliseconds: 500), () {
        _nextTrial();
      });
    });
  }

  void _handleTap() {
    if (!_canRespond || _responses.length > _currentTick) return;

    _responses.add(true);

    final hit = _isTarget;
    final falseAlarm = !_isTarget;

    _totalScore += ScoringEngine.calculateGoNoGoScore(hit, falseAlarm);

    setState(() {
      _canRespond = false;
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _stimulusTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

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
    final accuracy = (hits + correctRejections) / _totalTicks;

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
