import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';

class WordChainGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final dynamic difficulty;

  const WordChainGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<WordChainGame> createState() => _WordChainGameState();
}

class _WordChainGameState extends ConsumerState<WordChainGame> {
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentRound = 0;
  int _totalRounds = 15;
  int _timeLimit = 150;
  int _remainingTime = 150;

  List<bool> _responses = [];
  double _totalScore = 0;

  List<String> _wordChain = [];
  List<String> _options = [];
  int _correctOption = 0;

  final List<String> _categories = [
    'Animals',
    'Colors',
    'Food',
    'Countries',
    'Sports',
    'Professions'
  ];

  final Map<String, List<String>> _wordLists = {
    'Animals': [
      'Cat',
      'Dog',
      'Bird',
      'Fish',
      'Lion',
      'Tiger',
      'Bear',
      'Wolf',
      'Fox',
      'Deer'
    ],
    'Colors': [
      'Red',
      'Blue',
      'Green',
      'Yellow',
      'Purple',
      'Orange',
      'Pink',
      'Brown',
      'Black',
      'White'
    ],
    'Food': [
      'Apple',
      'Bread',
      'Cheese',
      'Pizza',
      'Pasta',
      'Rice',
      'Meat',
      'Fish',
      'Cake',
      'Soup'
    ],
    'Countries': [
      'USA',
      'Canada',
      'Mexico',
      'Brazil',
      'France',
      'Germany',
      'Italy',
      'Spain',
      'Japan',
      'China'
    ],
    'Sports': [
      'Soccer',
      'Basketball',
      'Tennis',
      'Golf',
      'Swimming',
      'Running',
      'Boxing',
      'Hockey',
      'Baseball',
      'Volleyball'
    ],
    'Professions': [
      'Doctor',
      'Teacher',
      'Engineer',
      'Artist',
      'Chef',
      'Pilot',
      'Nurse',
      'Lawyer',
      'Scientist',
      'Writer'
    ],
  };

  String _currentCategory = '';

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
          Icon(Icons.link,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Word Chain',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Look at the sequence of words\n'
            '• All words belong to the same category\n'
            '• Choose the word that continues the pattern\n'
            '• Categories include animals, colors, food, etc.\n'
            '• Tests verbal reasoning and categorization',
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
              Text('Round: ${_currentRound + 1}/$_totalRounds',
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
                  'Category: $_currentCategory',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Continue the word chain:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Word chain
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ..._wordChain.map((word) => Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          child: Text(
                            word,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )),
                    Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      child: const Text(
                        '?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Options
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      onPressed: () => _handleAnswer(index),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        _options[index],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
    final accuracy = _responses.where((r) => r).length / _totalRounds;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events,
              size: 64, color: Theme.of(context).colorScheme.tertiary),
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
                  _ResultRow('Rounds Completed', '$_currentRound'),
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

      if (_remainingTime <= 0 || _currentRound >= _totalRounds) {
        _endGame();
      }
    });

    _generateRound();
  }

  void _generateRound() {
    // Choose random category
    _currentCategory = _categories[_random.nextInt(_categories.length)];
    final words = _wordLists[_currentCategory]!;

    // Create chain of 3 words
    _wordChain.clear();
    final shuffledWords = List<String>.from(words)..shuffle(_random);

    for (int i = 0; i < 3; i++) {
      _wordChain.add(shuffledWords[i]);
    }

    // Correct answer is another word from same category
    final correctAnswer = shuffledWords[3];

    // Generate wrong options from other categories
    _options = [correctAnswer];
    while (_options.length < 4) {
      final wrongCategory = _categories[_random.nextInt(_categories.length)];
      if (wrongCategory != _currentCategory) {
        final wrongWords = _wordLists[wrongCategory]!;
        final wrongAnswer = wrongWords[_random.nextInt(wrongWords.length)];
        if (!_options.contains(wrongAnswer)) {
          _options.add(wrongAnswer);
        }
      }
    }

    _options.shuffle(_random);
    _correctOption = _options.indexOf(correctAnswer);

    setState(() {});
  }

  void _handleAnswer(int selectedOption) {
    final correct = selectedOption == _correctOption;
    _responses.add(correct);
    _totalScore += ScoringEngine.calculateWordChainScore(correct);

    _currentRound++;

    if (_currentRound >= _totalRounds) {
      _endGame();
    } else {
      _generateRound();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    final accuracy = _responses.where((r) => r).length / _totalRounds;

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
