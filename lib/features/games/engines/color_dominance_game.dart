import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/congratulations_utils.dart';

class ColorDominanceGame extends BaseGame {
  const ColorDominanceGame(
      {super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<ColorDominanceGame> createState() => _ColorDominanceGameState();
}

class _ColorDominanceGameState extends BaseGameState<ColorDominanceGame> {
  late Random _random;

  int _currentRound = 0;

  final List<int> _scores = [];

  // Color dominance specific variables
  List<List<Color>> _colorGrid = [];
  final Map<Color, int> _colorCounts = {};
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
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getColorDominanceConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _generateRound();
  }

  @override
  void onGamePaused() {
    // Color dominance doesn't need special pause handling
  }

  @override
  void onGameResumed() {
    // Color dominance doesn't need special resume handling
  }

  @override
  Widget buildStartScreen() {
    return _buildStartScreen();
  }

  @override
  Widget buildGameScreen() {
    return _buildGameScreen();
  }

  @override
  Widget buildEndScreen() {
    return _buildEndScreen();
  }

  void _generateRound() {
    _selectedAnswer = null;
    _showingResult = false;
    _colorCounts.clear();

    // Create 8x8 grid (64 squares)
    _colorGrid = List.generate(8, (i) => List.generate(8, (j) => Colors.grey));

    // Difficulty-based color distribution
    List<int> colorCounts;
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getColorDominanceConfig(widget.difficulty!);
      final gameSpecific = difficultyConfig.gameSpecific;
      colorCounts =
          (gameSpecific['colorCounts'] as List<int>?) ?? [25, 15, 12, 12];
    } else {
      colorCounts = [25, 15, 12, 12]; // Default moderate difficulty
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
    addScore(score);

    // Audio feedback removed

    setState(() {
      _showingResult = true;
    });

    // Auto advance after configured time
    addTimer(GameTimingConfig.autoAdvanceDelay, () {
      _nextRound();
    });
  }

  void _nextRound() {
    if (_currentRound + 1 >= totalRounds) {
      _endGame();
    } else {
      setState(() {
        _currentRound++;
      });
      _generateRound();
    }
  }

  void _startGame() {
    startGame();
  }

  void _endGame() {
    endGame();
  }

  @override
  void onGameEnded() {
    final correctCount = _scores.where((s) => s > 0).length;
    final accuracy = SafeMath.safeAccuracy(correctCount, totalRounds);
    recordSessionResult(accuracy: accuracy);
  }

  Widget _buildStartScreen() {
    return Center(
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Start Game', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildEndScreen() {
    final accuracy = totalRounds > 0
        ? (_scores.where((s) => s > 0).length / totalRounds * 100).round()
        : 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 24),
          Text(
            CongratulationsUtils.getCompletionTitle(accuracy.toDouble()),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              CongratulationsUtils.getCompletionMessage(
                  accuracy.toDouble(), totalScore.toInt(), totalRounds),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Final Score: ${totalScore.toInt()}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text('Accuracy: $accuracy%', style: const TextStyle(fontSize: 18)),
          Text('Rounds: $totalRounds', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return ResponsiveWrapper(
      child: Column(
        children: [
          // Game info
          Padding(
            padding:
                ResponsiveUtils.getScreenPadding(context).copyWith(bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Round: ${_currentRound + 1}/$totalRounds',
                    style: TextStyle(
                      fontSize: 14 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Time: ${remainingTime}s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Score: ${totalScore.toInt()}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 14 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Color grid - Responsive size container
          Expanded(
            child: Padding(
              padding: ResponsiveUtils.getScreenPadding(context)
                  .copyWith(top: 0, bottom: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use responsive game grid size
                  final gridSize = ResponsiveUtils.getGameGridSize(context);
                  final deviceType = ResponsiveUtils.getDeviceType(context);

                  // Calculate control section height based on device
                  final controlHeight = switch (deviceType) {
                    DeviceType.mobile => 140.0,
                    DeviceType.tablet => 160.0,
                    DeviceType.desktop => 180.0,
                  };

                  // Ensure grid fits with controls
                  final maxGridHeight = constraints.maxHeight -
                      controlHeight -
                      ResponsiveUtils.getSpacing(context);
                  final finalGridSize = gridSize.clamp(200.0, maxGridHeight);

                  return Column(
                    children: [
                      // Grid
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: finalGridSize,
                            height: finalGridSize,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 1,
                                    crossAxisSpacing: 1,
                                  ),
                                  itemCount: 64,
                                  itemBuilder: (context, index) {
                                    final row = index ~/ 8;
                                    final col = index % 8;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: _colorGrid[row][col],
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: ResponsiveUtils.getSpacing(context)),

                      // Result or options - Responsive bottom section
                      SizedBox(
                        height: controlHeight,
                        child: _showingResult
                            ? _buildResultSection()
                            : _buildOptionsSection(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    final buttonHeight = ResponsiveUtils.getButtonHeight(context);
    final iconSize =
        ResponsiveUtils.getIconSize(context, type: IconSizeType.small);
    final spacing =
        ResponsiveUtils.getSpacing(context, type: SpacingType.small);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Select the most frequent color:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.titleSmall!.fontSize! *
                    ResponsiveUtils.getFontScale(context),
              ),
        ),
        SizedBox(height: spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _colors.map((color) {
            final colorName = _getColorName(color);
            final isSelected = _selectedAnswer == colorName;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: GestureDetector(
                  onTap: () {
                    _selectAnswer(colorName);
                  },
                  child: Container(
                    height: switch (deviceType) {
                      DeviceType.mobile => 50.0,
                      DeviceType.tablet => 60.0,
                      DeviceType.desktop => 70.0,
                    },
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
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black26,
                              width: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing / 2),
                        Text(
                          colorName,
                          style: TextStyle(
                            fontSize: (switch (deviceType) {
                                  DeviceType.mobile => 9.0,
                                  DeviceType.tablet => 11.0,
                                  DeviceType.desktop => 13.0,
                                }) *
                                ResponsiveUtils.getFontScale(context),
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
        SizedBox(height: spacing),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: _selectedAnswer != null ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              textStyle: TextStyle(
                fontSize: 16 * ResponsiveUtils.getFontScale(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Submit Answer'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    final spacing = ResponsiveUtils.getSpacing(context, type: SpacingType.xs);

    return Container(
      padding: EdgeInsets.all(
          ResponsiveUtils.getSpacing(context, type: SpacingType.small)),
      decoration: BoxDecoration(
        color: _answeredCorrectly
            ? Theme.of(context).colorScheme.tertiaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _answeredCorrectly ? 'Correct!' : 'Incorrect!',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize! *
                      ResponsiveUtils.getFontScale(context),
                  color: _answeredCorrectly
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
          ),
          SizedBox(height: spacing),
          Text(
            'Answer: $_correctAnswer',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: (switch (deviceType) {
                        DeviceType.mobile => 12.0,
                        DeviceType.tablet => 14.0,
                        DeviceType.desktop => 16.0,
                      }) *
                      ResponsiveUtils.getFontScale(context),
                  color: _answeredCorrectly
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
          ),
          SizedBox(height: spacing),
          // Show color counts in a responsive layout with better visibility
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Color Counts:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                if (deviceType == DeviceType.desktop)
                  // Desktop: Show all counts in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: (_colorCounts.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)))
                        .map((entry) {
                      final colorName = _getColorName(entry.key);
                      final count = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: entry.key.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$colorName: $count',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontSize:
                                    11 * ResponsiveUtils.getFontScale(context),
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  // Mobile/Tablet: Show all 4 counts in 2x2 grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: (_colorCounts.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)))
                        .map((entry) {
                      final colorName = _getColorName(entry.key);
                      final count = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: entry.key.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: entry.key.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$colorName: $count',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontSize: (switch (deviceType) {
                                      DeviceType.mobile => 11.0,
                                      DeviceType.tablet => 13.0,
                                      DeviceType.desktop => 14.0,
                                    }) *
                                    ResponsiveUtils.getFontScale(context),
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
