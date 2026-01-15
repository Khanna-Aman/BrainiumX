import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';

class SpatialRotationGame extends BaseGame {
  const SpatialRotationGame(
      {super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<SpatialRotationGame> createState() =>
      _SpatialRotationGameState();
}

class _SpatialRotationGameState extends BaseGameState<SpatialRotationGame> {
  late Random _random;

  int _currentTrial = 0;
  final int _gridSize = 4;

  final List<bool> _responses = [];

  List<List<bool>> _originalShape = [];
  List<List<bool>> _rotatedShape = [];
  bool _isCorrectRotation = true;
  int _rotationAngle = 90;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _generateShapes();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getSpatialRotationConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _generateShapes();
  }

  @override
  void onGamePaused() {
    // Spatial rotation doesn't need special pause handling
  }

  @override
  void onGameResumed() {
    // Spatial rotation doesn't need special resume handling
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
          const Icon(Icons.rotate_right, size: 64, color: Colors.indigo),
          const SizedBox(height: 24),
          Text(
            'Spatial Rotation',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Look at the two shapes shown\n'
            '• Determine if the right shape is a rotation of the left\n'
            '• Tap SAME if they are the same shape rotated\n'
            '• Tap DIFFERENT if they are different shapes\n'
            '• Use your spatial reasoning skills!',
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Trial: ${_currentTrial + 1}/$totalRounds',
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Time: ${remainingTime}s',
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
          ),

          // Game Area
          Expanded(
            child: Padding(
              padding: ResponsiveUtils.getScreenPadding(context)
                  .copyWith(top: 0, bottom: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final deviceType = ResponsiveUtils.getDeviceType(context);
                  final spacing = ResponsiveUtils.getSpacing(context);
                  final buttonHeight = ResponsiveUtils.getButtonHeight(context);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Instruction
                      Text(
                        'Are these the same shape?',
                        style: TextStyle(
                          fontSize: switch (deviceType) {
                                DeviceType.mobile => 18.0,
                                DeviceType.tablet => 22.0,
                                DeviceType.desktop => 26.0,
                              } *
                              ResponsiveUtils.getFontScale(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: spacing * 2),

                      // Shape comparison
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child:
                                  _buildShapeGrid(_originalShape, 'Original'),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: spacing),
                              child: Icon(
                                Icons.arrow_forward,
                                size: switch (deviceType) {
                                  DeviceType.mobile => 24.0,
                                  DeviceType.tablet => 32.0,
                                  DeviceType.desktop => 40.0,
                                },
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: _buildShapeGrid(_rotatedShape, 'Rotated'),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacing * 2),

                      // Response buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: spacing / 2),
                              child: SizedBox(
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: () => _handleResponse(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    textStyle: TextStyle(
                                      fontSize: 18 *
                                          ResponsiveUtils.getFontScale(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('SAME'),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: spacing / 2),
                              child: SizedBox(
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: () => _handleResponse(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    textStyle: TextStyle(
                                      fontSize: 18 *
                                          ResponsiveUtils.getFontScale(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('DIFFERENT'),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildShapeGrid(List<List<bool>> shape, String label) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(context);
        final spacing =
            ResponsiveUtils.getSpacing(context, type: SpacingType.xs);

        // Responsive grid size
        final gridSize = switch (deviceType) {
          DeviceType.mobile => 100.0,
          DeviceType.tablet => 140.0,
          DeviceType.desktop => 180.0,
        };

        // Ensure grid fits in available width
        final maxWidth = constraints.maxWidth * 0.8;
        final finalGridSize = gridSize.clamp(80.0, maxWidth);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16 * ResponsiveUtils.getFontScale(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing),
            Container(
              width: finalGridSize,
              height: finalGridSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: _gridSize * _gridSize,
                  itemBuilder: (context, index) {
                    final row = index ~/ _gridSize;
                    final col = index % _gridSize;
                    final isActive = row < shape.length &&
                        col < shape[row].length &&
                        shape[row][col];

                    return Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / totalRounds;

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
                  _resultRow('Score', totalScore.toInt().toString()),
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
    startGame();
  }

  void _generateShapes() {
    // Generate a random shape based on grid size
    _originalShape = List.generate(
        _gridSize, (i) => List.generate(_gridSize, (j) => _random.nextBool()));

    // Decide if this should be a correct rotation or different shape
    _isCorrectRotation = _random.nextBool();

    if (_isCorrectRotation) {
      // Rotate the original shape
      _rotationAngle = [90, 180, 270][_random.nextInt(3)];
      _rotatedShape = _rotateShape(_originalShape, _rotationAngle);
    } else {
      // Generate a completely different shape
      _rotatedShape = List.generate(_gridSize,
          (i) => List.generate(_gridSize, (j) => _random.nextBool()));
    }

    setState(() {});
  }

  List<List<bool>> _rotateShape(List<List<bool>> shape, int angle) {
    final size = shape.length;
    List<List<bool>> rotated =
        List.generate(size, (i) => List.generate(size, (j) => false));

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        int newI, newJ;
        switch (angle) {
          case 90:
            newI = j;
            newJ = size - 1 - i;
            break;
          case 180:
            newI = size - 1 - i;
            newJ = size - 1 - j;
            break;
          case 270:
            newI = size - 1 - j;
            newJ = i;
            break;
          default:
            newI = i;
            newJ = j;
        }
        rotated[newI][newJ] = shape[i][j];
      }
    }

    return rotated;
  }

  void _handleResponse(bool userSaysSame) {
    final correct = userSaysSame == _isCorrectRotation;
    _responses.add(correct);
    final score = correct ? 100 : 0;
    addScore(score);

    _currentTrial++;

    if (_currentTrial >= totalRounds) {
      _endGame();
    } else {
      _generateShapes();
    }
  }

  void _endGame() {
    endGame();
  }

  @override
  void onGameEnded() {
    final accuracy = totalRounds > 0
        ? (_responses.where((r) => r).length / totalRounds * 100).round()
        : 0;
    recordSessionResult(accuracy: accuracy / 100.0);
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
