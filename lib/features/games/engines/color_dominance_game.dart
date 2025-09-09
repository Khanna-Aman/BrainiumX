import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';

import '../../../core/utils/question_tracker.dart';

import '../difficulty_selection_screen.dart' as difficulty_screen;

class ColorDominanceGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final difficulty_screen.DifficultyLevel? difficulty;

  const ColorDominanceGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<ColorDominanceGame> createState() => _ColorDominanceGameState();
}

class _ColorDominanceGameState extends ConsumerState<ColorDominanceGame>
    with QuestionTrackingMixin {
  @override
  GameId get gameId => widget.gameId;
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentRound = 0;
  int _totalRounds = 10;
  int _timeLimit = 90;
  int _remainingTime = 90;

  List<int> _scores = [];
  double _totalScore = 0;

  // Color dominance specific variables
  List<List<Color>> _colorGrid = [];
  Map<Color, int> _colorCounts = {};
  String _correctAnswer = '';
  String? _selectedAnswer;
  bool _showingResult = false;
  bool _answeredCorrectly = false;

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _random = Random();
    _configureDifficulty();
    _generateRound();
  }

  void _configureDifficulty() {
    // Configure based on difficulty level
    switch (widget.difficulty) {
      case difficulty_screen.DifficultyLevel.veryEasy:
        _totalRounds = 3;
        _timeLimit = 60;
        break;
      case difficulty_screen.DifficultyLevel.easy:
        _totalRounds = 5;
        _timeLimit = 75;
        break;
      case difficulty_screen.DifficultyLevel.medium:
        _totalRounds = 7;
        _timeLimit = 90;
        break;
      case difficulty_screen.DifficultyLevel.hard:
        _totalRounds = 10;
        _timeLimit = 120;
        break;
      default:
        _totalRounds = 5;
        _timeLimit = 75;
        break;
    }
    _remainingTime = _timeLimit;
  }

  void _generateRound() {
    _selectedAnswer = null;
    _showingResult = false;
    _colorCounts.clear();

    // Create 8x8 grid (64 squares)
    _colorGrid = List.generate(8, (i) => List.generate(8, (j) => Colors.grey));

    // Difficulty-based color distribution
    List<int> colorCounts;
    switch (widget.difficulty) {
      case difficulty_screen.DifficultyLevel.veryEasy:
        // Very obvious dominant color
        colorCounts = [35, 12, 10, 7]; // 35 vs 12 - very clear
        break;
      case difficulty_screen.DifficultyLevel.easy:
        // Clear dominant color
        colorCounts = [28, 15, 12, 9]; // 28 vs 15 - clear difference
        break;
      case difficulty_screen.DifficultyLevel.medium:
        // Moderate difference
        colorCounts = [22, 18, 14, 10]; // 22 vs 18 - need to count carefully
        break;
      case difficulty_screen.DifficultyLevel.hard:
        // Very close counts - hard to distinguish
        colorCounts = [18, 16, 15, 15]; // 18 vs 16 - very close
        break;
      default:
        colorCounts = [28, 15, 12, 9];
        break;
    }

    // Shuffle the counts and assign to random colors
    colorCounts.shuffle(_random);
    final colorAssignments = List.generate(4, (i) => i);
    colorAssignments.shuffle(_random);

    // Create all 64 positions and shuffle them
    final positions = <int>[];
    for (int i = 0; i < 64; i++) {
      positions.add(i);
    }
    positions.shuffle(_random);

    // Fill grid with colors based on counts
    int positionIndex = 0;
    for (int colorIndex = 0; colorIndex < 4; colorIndex++) {
      final color = _colors[colorAssignments[colorIndex]];
      final count = colorCounts[colorIndex];
      _colorCounts[color] = count;

      // Fill squares for this color
      for (int i = 0; i < count; i++) {
        final pos = positions[positionIndex++];
        final row = pos ~/ 8;
        final col = pos % 8;
        _colorGrid[row][col] = color;
      }
    }

    // Find the color with the highest count
    Color dominantColor = _colors[0];
    int maxCount = 0;
    _colorCounts.forEach((color, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantColor = color;
      }
    });

    _correctAnswer = _getColorName(dominantColor);
    setState(() {});
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.orange) return 'Orange';
    return 'Unknown';
  }

  void _selectAnswer(String colorName) {
    setState(() {
      _selectedAnswer = colorName;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    _answeredCorrectly = _selectedAnswer == _correctAnswer;

    final score = _answeredCorrectly ? 100 : 0;
    _scores.add(score);
    _totalScore += score;

    setState(() {
      _showingResult = true;
    });

    // Auto advance after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) _nextRound();
    });
  }

  void _nextRound() {
    if (_currentRound + 1 >= _totalRounds) {
      _endGame();
    } else {
      setState(() {
        _currentRound++;
        _generateRound();
      });
    }
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    setState(() {
      _gameEnded = true;
    });

    // Game completed - score is displayed in UI
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildStartScreen();
    }

    if (_gameEnded) {
      return _buildEndScreen();
    }

    return _buildGameScreen();
  }

  Widget _buildStartScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Dominance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.palette, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Find the Dominant Color',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Find which color appears most frequently in the grid!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Start Game', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndScreen() {
    final accuracy = _totalRounds > 0
        ? (_scores.where((s) => s > 0).length / _totalRounds * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Complete'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'Final Score: ${_totalScore.toInt()}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text('Accuracy: $accuracy%', style: const TextStyle(fontSize: 18)),
            Text('Rounds: $_totalRounds', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Dominance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Game info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Round: ${_currentRound + 1}/$_totalRounds'),
                Text('Time: ${_remainingTime}s'),
                Text('Score: ${_totalScore.toInt()}'),
              ],
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Which COLOR appears most frequently?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // Color grid
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: _colorGrid[row][col],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result or options
            if (_showingResult)
              _buildResultSection()
            else
              _buildOptionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        Text(
          'Select the most frequent color:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _colors.map((color) {
            final colorName = _getColorName(color);
            final isSelected = _selectedAnswer == colorName;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _selectAnswer(colorName),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          colorName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _selectedAnswer != null ? _submitAnswer : null,
          child: const Text('Submit Answer'),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _answeredCorrectly
            ? Theme.of(context).colorScheme.tertiaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _answeredCorrectly ? 'Correct!' : 'Incorrect!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _answeredCorrectly
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'The correct answer was "$_correctAnswer"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _answeredCorrectly
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Color counts:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _answeredCorrectly
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
          ),
          // Sort color counts in descending order
          ...(_colorCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .map((entry) {
            final colorName = _getColorName(entry.key);
            final count = entry.value;
            return Text(
              '$colorName: $count squares',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _answeredCorrectly
                        ? Theme.of(context).colorScheme.onTertiaryContainer
                        : Theme.of(context).colorScheme.onErrorContainer,
                  ),
            );
          }),
        ],
      ),
    );
  }
}
