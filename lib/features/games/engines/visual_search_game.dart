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

class VisualSearchGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final difficulty_screen.DifficultyLevel? difficulty;

  const VisualSearchGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<VisualSearchGame> createState() =>
      _ColorAreaComparisonGameState();
}

class _ColorAreaComparisonGameState extends ConsumerState<VisualSearchGame>
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

  // Color area comparison specific variables
  Map<Color, double> _colorAreas = {};
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
  }

  void _configureDifficulty() {
    if (widget.difficulty != null) {
      // Use difficulty-based configuration
      final difficultyConfig =
          DifficultyConfigProvider.getColorDominanceConfig(widget.difficulty!);
      _totalRounds = difficultyConfig.rounds;
      _timeLimit = difficultyConfig.timeLimit;
      _remainingTime = _timeLimit;
    }
    // If no difficulty specified, use default values (already set)
  }

  Color _getColorFromString(String colorStr) {
    switch (colorStr) {
      case 'Color(0xfff44336)':
        return Colors.red;
      case 'Color(0xff2196f3)':
        return Colors.blue;
      case 'Color(0xff4caf50)':
        return Colors.green;
      case 'Color(0xffff9800)':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.orange) return 'Orange';
    return 'Unknown';
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
            'Color Area Comparison',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Look at the colored areas and identify which color occupies the largest area.',
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
                  'Which COLOR occupies the LARGEST area?',
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

        // Color Areas Display
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: ColorAreaPainter(_colorAreas),
              size: Size.infinite,
            ),
          ),
        ),

        // Multiple Choice Options
        if (!_showingResult)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select the color that occupies the largest area:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _colors.map((color) {
                    final colorStr = color.toString();
                    final isSelected = _selectedAnswer == colorStr;
                    final colorName = _getColorName(color);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _selectAnswer(colorStr),
                          onPanEnd: (details) {
                            // Swipe right to select, swipe left to deselect
                            if (details.velocity.pixelsPerSecond.dx > 300) {
                              _selectAnswer(colorStr);
                            } else if (details.velocity.pixelsPerSecond.dx <
                                -300) {
                              _selectAnswer(''); // Deselect
                            }
                          },
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
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
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _selectedAnswer != null ? _submitAnswer : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit Answer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Extra bottom padding to prevent navigation button overlap
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
                Text(
                  'The correct answer was "${_getColorName(_getColorFromString(_correctAnswer))}"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _answeredCorrectly
                            ? Theme.of(context).colorScheme.onTertiaryContainer
                            : Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Area percentages:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _answeredCorrectly
                            ? Theme.of(context).colorScheme.onTertiaryContainer
                            : Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
                ..._colorAreas.entries.map((entry) {
                  final colorName = _getColorName(entry.key);
                  final percentage = (entry.value * 100).toInt();
                  return Text(
                    '$colorName: $percentage%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _answeredCorrectly
                              ? Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  );
                }),
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
    _selectedAnswer = null;
    _showingResult = false;

    // Generate unique round using question tracking
    final roundData = await generateUniqueQuestion<Map<String, dynamic>>(
      (round) => '${round['colors']}_${round['areas']}',
      () {
        // Generate balanced area percentages for each color
        final areas = <String, double>{};

        // Start with base areas that ensure all colors are visible
        final baseAreas = [
          0.15,
          0.20,
          0.25,
          0.40
        ]; // Minimum 15% each, one clearly larger
        baseAreas.shuffle(_random);

        // Assign areas to colors
        for (int i = 0; i < _colors.length; i++) {
          areas[_colors[i].toString()] = baseAreas[i];
        }

        // Add some random variation while keeping proportions
        final variation = 0.05; // 5% variation
        areas.updateAll((key, value) {
          final randomVariation = (_random.nextDouble() - 0.5) * variation;
          return (value + randomVariation)
              .clamp(0.1, 0.6); // Keep between 10% and 60%
        });

        // Normalize to ensure total is exactly 1.0
        final total = areas.values.reduce((a, b) => a + b);
        areas.updateAll((key, value) => value / total);

        return {
          'colors': _colors.map((c) => c.toString()).toList(),
          'areas': areas,
        };
      },
    );

    final colorAreas = roundData['areas'] as Map<String, double>;

    // Convert string keys back to Color objects
    _colorAreas.clear();
    colorAreas.forEach((colorStr, area) {
      final color = _getColorFromString(colorStr);
      _colorAreas[color] = area;
    });

    // Color areas generated

    // Find the color with the largest area
    _correctAnswer = '';
    double maxArea = 0;
    _colorAreas.forEach((color, area) {
      if (area > maxArea) {
        maxArea = area;
        _correctAnswer = color.toString();
      }
    });

    setState(() {});
  }

  void _selectAnswer(String colorStr) {
    setState(() {
      _selectedAnswer = colorStr;
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

class ColorAreaPainter extends CustomPainter {
  final Map<Color, double> colorAreas;

  ColorAreaPainter(this.colorAreas);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Fallback: if no color areas, show default pattern
    if (colorAreas.isEmpty) {
      // Draw 4 equal sections with default colors
      final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
      final sectionHeight = size.height / 4;

      for (int i = 0; i < 4; i++) {
        paint.color = colors[i];
        canvas.drawRect(
          Rect.fromLTWH(0, i * sectionHeight, size.width, sectionHeight),
          paint,
        );
      }
      return;
    }

    final areas = colorAreas.entries.toList();

    // Ensure we have exactly 4 colors
    if (areas.length != 4) return;

    // Simple approach: divide screen into 4 horizontal sections
    double currentY = 0;

    for (int i = 0; i < areas.length; i++) {
      final entry = areas[i];
      final sectionHeight = size.height * entry.value;

      paint.color = entry.key;
      canvas.drawRect(
        Rect.fromLTWH(0, currentY, size.width, sectionHeight),
        paint,
      );
      currentY += sectionHeight;
    }
  }

  @override
  bool shouldRepaint(ColorAreaPainter oldDelegate) {
    return colorAreas != oldDelegate.colorAreas;
  }
}
