import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';

import '../../../core/utils/question_tracker.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../difficulty_selection_screen.dart' as difficulty_screen;

class ColorMatchGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final difficulty_screen.DifficultyLevel? difficulty;

  const ColorMatchGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends ConsumerState<ColorMatchGame>
    with QuestionTrackingMixin {
  @override
  GameId get gameId => widget.gameId;
  late Random _random;
  Timer? _gameTimer;
  Timer? _sequenceTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentRound = 0;
  int _totalRounds = 12;
  int _timeLimit = 90;
  int _remainingTime = 90;

  List<int> _scores = [];
  double _totalScore = 0;

  List<Color> _sequence = [];
  List<Color> _userSequence = [];
  bool _showingSequence = false;
  bool _acceptingInput = false;
  bool _showingResult = false;
  bool _answeredCorrectly = false;
  int _sequenceIndex = 0;

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _random = Random();
    _configureDifficulty();
  }

  void _configureDifficulty() {
    if (widget.difficulty != null) {
      // Use difficulty-based configuration
      final difficultyConfig =
          DifficultyConfigProvider.getColorMatchConfig(widget.difficulty!);
      _totalRounds = difficultyConfig.rounds;
      _timeLimit = difficultyConfig.timeLimit;
      _remainingTime = _timeLimit;
    }
    // If no difficulty specified, use default values (already set)
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _sequenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildStartScreen();
    } else if (_gameEnded) {
      return _buildResults();
    } else {
      return _buildGameArea();
    }
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Color Match',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Watch the sequence of colors, then repeat it in the same order.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
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
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _showingSequence
                      ? 'Watch the sequence...'
                      : _acceptingInput
                          ? 'Repeat the sequence'
                          : 'Get ready...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Color Grid
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final color = _colors[index];
                final isHighlighted = _showingSequence &&
                    _sequenceIndex < _sequence.length &&
                    _sequence[_sequenceIndex] == color;

                return GestureDetector(
                  onTap: _acceptingInput ? () => _selectColor(color) : null,
                  onPanEnd: _acceptingInput
                      ? (details) {
                          // Swipe up to select color
                          if (details.velocity.pixelsPerSecond.dy < -300) {
                            _selectColor(color);
                          }
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHighlighted ? Colors.white : Colors.black26,
                        width: isHighlighted ? 6 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: isHighlighted ? 12 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // User sequence display
        if (_acceptingInput || _showingResult)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Your sequence:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _sequence.length; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: i < _userSequence.length
                              ? _userSequence[i]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_acceptingInput)
                  ElevatedButton(
                    onPressed: _userSequence.length == _sequence.length
                        ? _submitAnswer
                        : null,
                    child: const Text('Submit'),
                  ),
              ],
            ),
          ),

        // Show result
        if (_showingResult)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _answeredCorrectly
                  ? Theme.of(context).colorScheme.tertiaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
            ),
            child: Column(
              children: [
                Icon(
                  _answeredCorrectly ? Icons.check_circle : Icons.cancel,
                  size: 48,
                  color: _answeredCorrectly
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  _answeredCorrectly ? 'Correct!' : 'Incorrect!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _answeredCorrectly
                            ? Theme.of(context).colorScheme.onTertiaryContainer
                            : Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _nextRound,
                  child: Text(_currentRound + 1 < _totalRounds
                      ? 'Next Round'
                      : 'Finish'),
                ),
              ],
            ),
          ),

        // Extra bottom padding to prevent navigation button overlap
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }

  Widget _buildResults() {
    final accuracy = _scores.isNotEmpty
        ? _scores.where((score) => score > 0).length / _scores.length
        : 0;

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
                  _resultRow('Total Score', _totalScore.toInt().toString()),
                  _resultRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                  _resultRow('Rounds Completed', '$_currentRound'),
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

      if (_remainingTime <= 0) {
        _endGame();
      }
    });

    _generateRound();
  }

  void _generateRound() async {
    _sequence.clear();
    _userSequence.clear();
    _showingSequence = false;
    _acceptingInput = false;
    _showingResult = false;
    _sequenceIndex = 0;

    // Generate sequence length based on round (starts at 3, increases every 2 rounds)
    final sequenceLength = 3 + (_currentRound ~/ 2);

    // Generate unique sequence using question tracking
    final colorSequence = await generateUniqueQuestion<List<Color>>(
      (sequence) => QuestionKeyGenerator.colorMatchKey(
        sequence.map((c) => c.value.toString()).toList(),
      ),
      () {
        final sequence = <Color>[];
        for (int i = 0; i < sequenceLength; i++) {
          sequence.add(_colors[_random.nextInt(_colors.length)]);
        }
        return sequence;
      },
    );

    _sequence = colorSequence;

    // Start showing sequence after a brief delay
    Timer(const Duration(milliseconds: 500), () {
      _showSequence();
    });

    setState(() {});
  }

  void _showSequence() {
    setState(() {
      _showingSequence = true;
      _sequenceIndex = 0;
    });

    _sequenceTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _sequenceIndex++;
      });

      if (_sequenceIndex >= _sequence.length) {
        timer.cancel();
        // Brief pause before accepting input
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            _showingSequence = false;
            _acceptingInput = true;
          });
        });
      }
    });
  }

  void _selectColor(Color color) {
    if (!_acceptingInput || _userSequence.length >= _sequence.length) return;

    setState(() {
      _userSequence.add(color);
    });
  }

  void _submitAnswer() {
    if (_userSequence.length != _sequence.length) return;

    _answeredCorrectly = true;
    for (int i = 0; i < _sequence.length; i++) {
      if (_userSequence[i] != _sequence[i]) {
        _answeredCorrectly = false;
        break;
      }
    }

    final score = _answeredCorrectly ? 100 : 0;
    _scores.add(score);
    _totalScore += score;

    setState(() {
      _acceptingInput = false;
      _showingResult = true;
    });

    // Auto advance after 2 seconds
    Timer(const Duration(seconds: 2), () {
      _nextRound();
    });
  }

  void _nextRound() {
    _currentRound++;
    if (_currentRound >= _totalRounds) {
      _endGame();
    } else {
      _generateRound();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _sequenceTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    // Record result
    final accuracy = _scores.isNotEmpty
        ? _scores.where((score) => score > 0).length / _scores.length
        : 0;

    final result = SessionResult(
      sessionId:
          ref.read(sessionProvider).currentSessionId ?? const Uuid().v4(),
      gameId: widget.gameId,
      score: _totalScore,
      accuracy: accuracy.toDouble(),
      timestamp: DateTime.now(),
      reactionTime: 0, // Not applicable for this game
    );

    ref.read(sessionProvider.notifier).recordGameResult(result);
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
