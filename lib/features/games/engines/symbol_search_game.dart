import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class SymbolSearchGame extends ConsumerStatefulWidget {
  final GameId gameId;

  const SymbolSearchGame({super.key, required this.gameId});

  @override
  ConsumerState<SymbolSearchGame> createState() => _SymbolSearchGameState();
}

class _SymbolSearchGameState extends ConsumerState<SymbolSearchGame> {
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentTrial = 0;
  int _totalTrials = 20;
  int _timeLimit = 150;
  int _remainingTime = 150;

  List<bool> _responses = [];
  double _totalScore = 0;

  List<String> _targetSymbols = [];
  List<String> _searchSymbols = [];
  bool _hasTarget = false;

  final List<String> _allSymbols = [
    '◆',
    '●',
    '▲',
    '■',
    '★',
    '♦',
    '♠',
    '♣',
    '♥',
    '◊',
    '▼',
    '◀',
    '▶',
    '⬟',
    '⬢'
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
          const Icon(Icons.search, size: 64, color: Colors.deepPurple),
          const SizedBox(height: 24),
          Text(
            'Symbol Search',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Look at the target symbols on the left\n'
            '• Search for ANY of these symbols in the grid\n'
            '• Tap YES if you find a target symbol\n'
            '• Tap NO if none of the targets are present\n'
            '• Work quickly but accurately!',
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Target symbols
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text(
                        'Find these:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _targetSymbols
                              .map((symbol) => Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      symbol,
                                      style: const TextStyle(
                                          fontSize: 32, color: Colors.blue),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Search grid
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Text(
                        'Search in this grid:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _searchSymbols.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _searchSymbols[index],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Response buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _handleResponse(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('YES - Found Target',
                    style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () => _handleResponse(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('NO - Not Found',
                    style: TextStyle(fontSize: 16)),
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
                  _ResultRow('Score', _totalScore.toInt().toString()),
                  _ResultRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                  _ResultRow('Trials Completed', '$_currentTrial'),
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

      if (_remainingTime <= 0 || _currentTrial >= _totalTrials) {
        _endGame();
      }
    });

    _generateTrial();
  }

  void _generateTrial() {
    // Generate 2-3 target symbols
    _targetSymbols.clear();
    final numTargets = 2 + _random.nextInt(2);
    final shuffledSymbols = List<String>.from(_allSymbols)..shuffle(_random);

    for (int i = 0; i < numTargets; i++) {
      _targetSymbols.add(shuffledSymbols[i]);
    }

    // Generate search grid (16 symbols)
    _searchSymbols.clear();
    _hasTarget = _random.nextBool();

    if (_hasTarget) {
      // Include at least one target
      _searchSymbols
          .add(_targetSymbols[_random.nextInt(_targetSymbols.length)]);

      // Fill rest with random symbols
      for (int i = 1; i < 16; i++) {
        _searchSymbols.add(_allSymbols[_random.nextInt(_allSymbols.length)]);
      }
    } else {
      // Fill with symbols that are NOT targets
      final nonTargets =
          _allSymbols.where((s) => !_targetSymbols.contains(s)).toList();

      for (int i = 0; i < 16; i++) {
        _searchSymbols.add(nonTargets[_random.nextInt(nonTargets.length)]);
      }
    }

    _searchSymbols.shuffle(_random);
    setState(() {});
  }

  void _handleResponse(bool userSaysFound) {
    final correct = userSaysFound == _hasTarget;
    _responses.add(correct);
    _totalScore += ScoringEngine.calculateSymbolSearchScore(correct);

    _currentTrial++;

    if (_currentTrial >= _totalTrials) {
      _endGame();
    } else {
      _generateTrial();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

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
