import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';

class FocusShiftGame extends BaseGame {
  const FocusShiftGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<FocusShiftGame> createState() => _FocusShiftGameState();
}

class _FocusShiftGameState extends BaseGameState<FocusShiftGame> {
  late Random _random;
  Timer? _taskTimer;

  bool _waitingForResponse = false;

  int _currentRound = 0;
  int _responseTimeLimit = 3000;

  final List<int> _scores = [];

  // Focus shift specific variables
  String _currentTask = '';
  String _currentStimulus = '';
  Color _currentColor = Colors.red;
  String _correctAnswer = '';

  final List<String> _shapes = ['●', '■', '▲', '◆'];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];
  final List<String> _colorNames = ['RED', 'BLUE', 'GREEN', 'YELLOW'];
  final List<String> _shapeNames = ['CIRCLE', 'SQUARE', 'TRIANGLE', 'DIAMOND'];

  @override
  void initState() {
    super.initState();
    _random = Random();
    _generateTask();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getFocusShiftConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
      final gameSpecific = difficultyConfig.gameSpecific;
      _responseTimeLimit = gameSpecific['responseTime'] as int? ?? 5000;
    }
  }

  @override
  void onGameStarted() {
    _startRound();
  }

  @override
  void onGamePaused() {
    _taskTimer?.cancel();
  }

  @override
  void onGameResumed() {
    // Resume task timer if needed
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

  void _generateTask() {
    // Randomly choose between color task and shape task
    final isColorTask = _random.nextBool();
    final shapeIndex = _random.nextInt(_shapes.length);
    final colorIndex = _random.nextInt(_colors.length);

    setState(() {
      _currentStimulus = _shapes[shapeIndex];
      _currentColor = _colors[colorIndex];

      if (isColorTask) {
        _currentTask = 'What COLOR is this?';
        _correctAnswer = _colorNames[colorIndex];
      } else {
        _currentTask = 'What SHAPE is this?';
        _correctAnswer = _shapeNames[shapeIndex];
      }

      _waitingForResponse = true;
    });

    // Auto-advance if no response
    _taskTimer = Timer(Duration(milliseconds: _responseTimeLimit), () {
      if (_waitingForResponse) {
        _handleResponse('');
      }
    });
  }

  void _startGame() {
    startGame();
  }

  void _startRound() {
    _generateTask();
    _showStimulus();
  }

  void _showStimulus() {
    setState(() {
      _waitingForResponse = true;
    });

    // Auto timeout after response time limit
    _taskTimer = Timer(Duration(milliseconds: _responseTimeLimit), () {
      if (_waitingForResponse) {
        _handleResponse(''); // Empty response = timeout
      }
    });
  }

  void _handleResponse(String response) {
    _taskTimer?.cancel();

    final isCorrect = response == _correctAnswer;
    final score = isCorrect ? 100 : 0;
    _scores.add(score);
    addScore(score);

    setState(() {
      _waitingForResponse = false;
    });

    // Brief pause before next task
    addTimer(GameConstants.sequenceDelay, () {
      _nextRound();
    });
  }

  void _nextRound() {
    if (_currentRound + 1 >= totalRounds) {
      _endGame();
    } else {
      setState(() {
        _currentRound++;
        _generateTask();
      });
    }
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 80, color: Colors.purple),
            const SizedBox(height: 24),
            Text(
              'Focus Shift',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Switch between identifying colors and shapes. Read the task carefully!',
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
    final accuracy =
        _scores.where((score) => score > 0).length / totalRounds * 100;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'Final Score: ${totalScore.toInt()}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text('Accuracy: ${accuracy.toInt()}%',
                style: const TextStyle(fontSize: 18)),
            Text('Rounds: $totalRounds', style: const TextStyle(fontSize: 18)),
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
    return ResponsiveWrapper(
      child: Padding(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Column(
          children: [
            // Game info
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
                    overflow: TextOverflow.ellipsis,
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
                    overflow: TextOverflow.ellipsis,
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),

            // Task instruction
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentTask,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge!.fontSize! *
                              ResponsiveUtils.getFontScale(context),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context) * 1.5),

            // Stimulus
            LayoutBuilder(
              builder: (context, constraints) {
                final deviceType = ResponsiveUtils.getDeviceType(context);
                final stimulusSize = switch (deviceType) {
                  DeviceType.mobile => 100.0,
                  DeviceType.tablet => 140.0,
                  DeviceType.desktop => 180.0,
                };

                return Container(
                  width: stimulusSize,
                  height: stimulusSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _currentStimulus,
                      style: TextStyle(
                        fontSize: switch (deviceType) {
                              DeviceType.mobile => 60.0,
                              DeviceType.tablet => 80.0,
                              DeviceType.desktop => 100.0,
                            } *
                            ResponsiveUtils.getFontScale(context),
                        color: _currentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context) * 1.5),

            // Response buttons
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final deviceType = ResponsiveUtils.getDeviceType(context);
                  final spacing = ResponsiveUtils.getSpacing(context);

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: switch (deviceType) {
                      DeviceType.mobile => 2.0,
                      DeviceType.tablet => 2.5,
                      DeviceType.desktop => 3.0,
                    },
                    children: [
                      ..._colorNames
                          .map((colorName) => _buildResponseButton(colorName)),
                      ..._shapeNames
                          .map((shapeName) => _buildResponseButton(shapeName)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseButton(String label) {
    return ElevatedButton(
      onPressed: _waitingForResponse ? () => _handleResponse(label) : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
        textStyle: TextStyle(
          fontSize: 16 * ResponsiveUtils.getFontScale(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
      ),
    );
  }
}
