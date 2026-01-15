import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/utils/object_pool.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';

class MemoryGridGame extends BaseGame {
  const MemoryGridGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<MemoryGridGame> createState() => _MemoryGridGameState();
}

class _MemoryGridGameState extends BaseGameState<MemoryGridGame> {
  late Random _random;
  Timer? _phaseTimer;

  bool _showingPattern = false;
  bool _recallPhase = false;

  int _currentRound = 0;
  int _gridSize = GameConstants.defaultGridSize;
  int _sequenceLength = 3;

  List<bool> _responses = [];

  List<int> _targetCells = [];
  List<int> _selectedCells = [];

  @override
  void initState() {
    super.initState();
    _random = Random();
    _responses = BoolPool.getResponseList();
    _targetCells = IntPool.getIntList();
    _selectedCells = IntPool.getIntList();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getMemoryGridConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
      _gridSize = difficultyConfig.gameSpecific['gridSize'] as int;
      _sequenceLength = difficultyConfig.gameSpecific['sequenceLength'] as int;
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    BoolPool.releaseResponseList(_responses);
    IntPool.releaseIntList(_targetCells);
    IntPool.releaseIntList(_selectedCells);
    super.dispose();
  }

  @override
  void onGameStarted() {
    _startRound();
  }

  @override
  void onGamePaused() {
    _phaseTimer?.cancel();
  }

  @override
  void onGameResumed() {
    if (_showingPattern) {
      _startRound();
    }
  }

  @override
  Widget buildStartScreen() {
    return _buildInstructions();
  }

  @override
  Widget buildGameScreen() {
    return _buildGameArea();
  }

  @override
  Widget buildEndScreen() {
    return _buildResults();
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_4x4,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Memory Grid',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Watch the grid carefully\n'
            '• Some squares will light up briefly\n'
            '• Remember which squares were highlighted\n'
            '• Then tap the squares you remember\n'
            '• Complete rounds with increasing difficulty\n'
            '• Difficulty adapts to your skill level:\n'
            '  - Very Easy: 3 rounds, 3×3 grid\n'
            '  - Easy: 5 rounds, 4×4 grid\n'
            '  - Medium: 8 rounds, 4×4 grid\n'
            '  - Hard: 12 rounds, 5×5 grid',
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
    return ResponsiveWrapper(
      child: Column(
        children: [
          // HUD
          Container(
            padding:
                ResponsiveUtils.getScreenPadding(context).copyWith(bottom: 0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Round: ${_currentRound + 1}/$totalRounds',
                        style: TextStyle(
                          fontSize: 16 * ResponsiveUtils.getFontScale(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Time: $remainingTime s',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16 * ResponsiveUtils.getFontScale(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Score: ${totalScore.toInt()}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 16 * ResponsiveUtils.getFontScale(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: ResponsiveUtils.getSpacing(context,
                        type: SpacingType.small)),
                Text(
                  _showingPattern
                      ? 'Memorize the pattern...'
                      : _recallPhase
                          ? 'Tap the squares you remember'
                          : 'Get ready...',
                  style: TextStyle(
                    fontSize: 18 * ResponsiveUtils.getFontScale(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Game Area
          Expanded(
            child: Padding(
              padding: ResponsiveUtils.getScreenPadding(context)
                  .copyWith(top: 0, bottom: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gridSize = ResponsiveUtils.getGameGridSize(context);
                  final deviceType = ResponsiveUtils.getDeviceType(context);

                  // Calculate button area height
                  final buttonHeight =
                      ResponsiveUtils.getButtonHeight(context) +
                          ResponsiveUtils.getSpacing(context) * 2;

                  // Ensure grid fits with button area
                  final maxGridHeight = constraints.maxHeight - buttonHeight;
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
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _gridSize,
                                    crossAxisSpacing: switch (deviceType) {
                                      DeviceType.mobile => 2.0,
                                      DeviceType.tablet => 3.0,
                                      DeviceType.desktop => 4.0,
                                    },
                                    mainAxisSpacing: switch (deviceType) {
                                      DeviceType.mobile => 2.0,
                                      DeviceType.tablet => 3.0,
                                      DeviceType.desktop => 4.0,
                                    },
                                  ),
                                  itemCount: _gridSize * _gridSize,
                                  itemBuilder: (context, index) {
                                    return RepaintBoundary(
                                      child: _MemoryGridCell(
                                        index: index,
                                        isTarget: _targetCells.contains(index),
                                        isSelected:
                                            _selectedCells.contains(index),
                                        showingPattern: _showingPattern,
                                        recallPhase: _recallPhase,
                                        onTap: _recallPhase
                                            ? () => _handleCellTap(index)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Button area with fixed height to prevent layout shift
                      SizedBox(
                        height: buttonHeight,
                        child: Padding(
                          padding: EdgeInsets.all(
                              ResponsiveUtils.getSpacing(context)),
                          child: _recallPhase
                              ? SizedBox(
                                  width: double.infinity,
                                  height:
                                      ResponsiveUtils.getButtonHeight(context),
                                  child: ElevatedButton(
                                    onPressed: _submitAnswer,
                                    style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(
                                        fontSize: 18 *
                                            ResponsiveUtils.getFontScale(
                                                context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: const Text('Submit'),
                                  ),
                                )
                              : const SizedBox(), // Empty space when not in recall phase
                        ),
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

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / totalRounds;
    final (congratsMessage, encouragementMessage) =
        _getCongratulationsMessage(accuracy);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events,
              size: 64, color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(height: 24),
          Text(
            congratsMessage,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            encouragementMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _resultRow('Score', totalScore.toInt().toString()),
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
    startGame();
  }

  void _startRound() {
    // Get difficulty configuration
    // Use configured sequence length
    final numTargets = _sequenceLength;

    _targetCells.clear();
    _selectedCells.clear();

    // Generate random target cells
    while (_targetCells.length < numTargets) {
      final cell = _random.nextInt(_gridSize * _gridSize);
      if (!_targetCells.contains(cell)) {
        _targetCells.add(cell);
      }
    }

    setState(() {
      _showingPattern = true;
      _recallPhase = false;
    });

    // Show pattern for configured time
    _phaseTimer = addTimer(GameTimingConfig.memoryGridPatternTime, () {
      setState(() {
        _showingPattern = false;
        _recallPhase = true;
      });
    });
  }

  void _handleCellTap(int index) {
    setState(() {
      if (_selectedCells.contains(index)) {
        _selectedCells.remove(index);
      } else {
        _selectedCells.add(index);
      }
    });
  }

  void _submitAnswer() {
    final correct = _selectedCells.toSet().containsAll(_targetCells) &&
        _targetCells.toSet().containsAll(_selectedCells);

    _responses.add(correct);
    final score = ScoringEngine.calculateMemoryGridScore(correct);
    addScore(score.toInt());

    _currentRound++;

    if (_currentRound >= totalRounds) {
      _endGame();
    } else {
      _startRound();
    }
  }

  void _endGame() {
    endGame();
  }

  @override
  void onGameEnded() {
    _phaseTimer?.cancel();

    // Calculate accuracy safely
    final correctCount = _responses.where((r) => r).length;
    final accuracy = SafeMath.safeAccuracy(correctCount, totalRounds);

    recordSessionResult(accuracy: accuracy);
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _getCongratulationsMessage(double accuracy) {
    if (accuracy >= 0.9) {
      return (
        'Outstanding!',
        'Your memory is incredible! You\'re a true champion!'
      );
    } else if (accuracy >= 0.8) {
      return (
        'Excellent Work!',
        'Amazing memory skills! You\'re getting really good at this!'
      );
    } else if (accuracy >= 0.7) {
      return (
        'Great Job!',
        'Your memory is improving! Keep up the fantastic work!'
      );
    } else if (accuracy >= 0.6) {
      return (
        'Well Done!',
        'Good effort! Your memory skills are developing nicely!'
      );
    } else if (accuracy >= 0.5) {
      return (
        'Nice Try!',
        'You\'re learning! Every attempt makes your memory stronger!'
      );
    } else {
      return (
        'Keep Going!',
        'Practice makes perfect! Your memory will improve with each game!'
      );
    }
  }
}

/// Optimized grid cell widget with RepaintBoundary for better performance
class _MemoryGridCell extends StatelessWidget {
  final int index;
  final bool isTarget;
  final bool isSelected;
  final bool showingPattern;
  final bool recallPhase;
  final VoidCallback? onTap;

  const _MemoryGridCell({
    required this.index,
    required this.isTarget,
    required this.isSelected,
    required this.showingPattern,
    required this.recallPhase,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (showingPattern && isTarget) {
      color = Theme.of(context).colorScheme.primary;
    } else if (recallPhase && isSelected) {
      color = Theme.of(context).colorScheme.tertiary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
