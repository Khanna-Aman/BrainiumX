import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/utils/object_pool.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';

class ArithmeticSprintGame extends BaseGame {
  const ArithmeticSprintGame(
      {super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<ArithmeticSprintGame> createState() =>
      _ArithmeticSprintGameState();
}

class _ArithmeticSprintGameState extends BaseGameState<ArithmeticSprintGame> {
  late Random _random;

  int _currentQuestion = 0;

  List<bool> _responses = [];

  String _equation = '';
  int _correctAnswer = 0;
  List<int> _options = [];

  @override
  void initState() {
    super.initState();
    _random = Random();
    _responses = BoolPool.getResponseList();
  }

  @override
  void dispose() {
    BoolPool.releaseResponseList(_responses);
    super.dispose();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getArithmeticSprintConfig(
              widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _generateQuestion();
  }

  @override
  void onGamePaused() {
    // Arithmetic sprint doesn't need special pause handling
  }

  @override
  void onGameResumed() {
    // Arithmetic sprint doesn't need special resume handling
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
          const Icon(Icons.calculate, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          Text(
            'Arithmetic Sprint',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Solve math problems as quickly as possible\n'
            '• Choose the correct answer from 4 options\n'
            '• Problems include +, -, ×, ÷\n'
            '• Work fast but stay accurate\n'
            '• Tests mental arithmetic speed',
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
                    'Question: ${_currentQuestion + 1}/$totalRounds',
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

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Equation
                      Container(
                        padding: EdgeInsets.all(spacing),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _equation,
                          style: TextStyle(
                            fontSize: switch (deviceType) {
                                  DeviceType.mobile => 36.0,
                                  DeviceType.tablet => 48.0,
                                  DeviceType.desktop => 60.0,
                                } *
                                ResponsiveUtils.getFontScale(context),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),

                      SizedBox(height: spacing * 2),

                      // Answer options
                      Flexible(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: switch (deviceType) {
                              DeviceType.mobile => 2.0,
                              DeviceType.tablet => 2.5,
                              DeviceType.desktop => 3.0,
                            },
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                              onPressed: () => _handleAnswer(_options[index]),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(spacing),
                                textStyle: TextStyle(
                                  fontSize: switch (deviceType) {
                                        DeviceType.mobile => 20.0,
                                        DeviceType.tablet => 24.0,
                                        DeviceType.desktop => 28.0,
                                      } *
                                      ResponsiveUtils.getFontScale(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Text('${_options[index]}'),
                            );
                          },
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
    final correctCount = _responses.where((r) => r).length;
    final accuracy = SafeMath.safeAccuracy(correctCount, totalRounds);

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
                  _resultRow('Questions Completed', '$_currentQuestion'),
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

  void _generateQuestion() async {
    // Use simple difficulty-based configuration
    int maxNumber;
    List<String> operations;

    // Use difficulty-based configuration
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getArithmeticSprintConfig(
              widget.difficulty!);
      final gameSpecific = difficultyConfig.gameSpecific;
      maxNumber = gameSpecific['maxNumber'] as int? ?? 50;
      operations = (gameSpecific['operations'] as List<String>?) ?? ['+', '-'];
    } else {
      maxNumber = 50;
      operations = ['+', '-'];
    }

    // Generate question
    final operation = operations[_random.nextInt(operations.length)];

    int a, b, correctAnswer;

    switch (operation) {
      case '+':
        a = 1 + _random.nextInt(maxNumber);
        b = 1 + _random.nextInt(maxNumber);
        correctAnswer = a + b;
        break;
      case '-':
        a = maxNumber ~/ 2 + _random.nextInt(maxNumber ~/ 2);
        b = 1 + _random.nextInt(a);
        correctAnswer = a - b;
        break;
      case '×':
        final maxFactor = (maxNumber / 10).ceil().clamp(2, 12);
        a = 2 + _random.nextInt(maxFactor);
        b = 2 + _random.nextInt(maxFactor);
        correctAnswer = a * b;
        break;
      case '÷':
        final maxFactor = (maxNumber / 10).ceil().clamp(2, 12);
        correctAnswer = 2 + _random.nextInt(maxFactor);
        b = 2 + _random.nextInt(maxFactor);
        a = correctAnswer * b;
        break;
      default:
        a = 10;
        b = 5;
        correctAnswer = 15;
    }

    _correctAnswer = correctAnswer;
    _equation = '$a $operation $b = ?';

    // Generate options
    _options = [_correctAnswer];
    while (_options.length < 4) {
      int wrongAnswer;
      if (operation == '÷') {
        wrongAnswer = _correctAnswer + _random.nextInt(10) - 5;
      } else {
        wrongAnswer = _correctAnswer + _random.nextInt(20) - 10;
      }

      if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }

    _options.shuffle(_random);
    setState(() {});
  }

  void _handleAnswer(int answer) {
    final correct = answer == _correctAnswer;
    _responses.add(correct);
    final score = ScoringEngine.calculateArithmeticScore(correct);
    addScore(score.toInt());

    _currentQuestion++;

    if (_currentQuestion >= totalRounds) {
      _endGame();
    } else {
      _generateQuestion();
    }
  }

  void _endGame() {
    endGame();
  }

  @override
  void onGameEnded() {
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
}
