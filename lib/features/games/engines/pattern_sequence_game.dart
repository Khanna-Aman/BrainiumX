import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/congratulations_utils.dart';
import '../../../core/constants/game_constants.dart';
import '../difficulty_selection_screen.dart';

class PatternSequenceGame extends BaseGame {
  const PatternSequenceGame(
      {super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<PatternSequenceGame> createState() =>
      _PatternSequenceGameState();
}

class _PatternSequenceGameState extends BaseGameState<PatternSequenceGame> {
  late Random _random;
  int _currentRound = 0;
  List<int> _currentSequence = [];
  int _correctAnswer = 0;
  List<int> _options = [];
  String _sequenceType = '';
  final List<bool> _responses = [];
  bool _showingResult = false;
  bool _answeredCorrectly = false;
  String _explanation = '';

  @override
  void initState() {
    super.initState();
    _random = Random();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getMemoryGridConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _generateSequence();
  }

  void _generateSequence() {
    final sequenceTypes = switch (widget.difficulty) {
      DifficultyLevel.easy => ['arithmetic', 'geometric'],
      DifficultyLevel.medium => ['arithmetic', 'geometric', 'fibonacci'],
      DifficultyLevel.hard => [
          'arithmetic',
          'geometric',
          'fibonacci',
          'square'
        ],
      DifficultyLevel.expert => [
          'arithmetic',
          'geometric',
          'fibonacci',
          'square',
          'prime'
        ],
      _ => ['arithmetic', 'geometric'],
    };

    _sequenceType = sequenceTypes[_random.nextInt(sequenceTypes.length)];
    _currentSequence = [];

    switch (_sequenceType) {
      case 'arithmetic':
        _generateArithmeticSequence();
        break;
      case 'geometric':
        _generateGeometricSequence();
        break;
      case 'fibonacci':
        _generateFibonacciSequence();
        break;
      case 'square':
        _generateSquareSequence();
        break;
      case 'prime':
        _generatePrimeSequence();
        break;
    }

    _generateOptions();
  }

  void _generateArithmeticSequence() {
    final start = _random.nextInt(10) + 1;
    final diff = _random.nextInt(5) + 1;

    _currentSequence = [start];
    for (int i = 1; i < 5; i++) {
      _currentSequence.add(start + (diff * i));
    }

    _correctAnswer = start + (diff * 5);
    _explanation = 'Arithmetic sequence: add $diff each time';
  }

  void _generateGeometricSequence() {
    final start = _random.nextInt(3) + 2;
    final ratio = _random.nextInt(3) + 2;

    _currentSequence = [start];
    for (int i = 1; i < 5; i++) {
      _currentSequence.add(start * pow(ratio, i).toInt());
    }

    _correctAnswer = start * pow(ratio, 5).toInt();
    _explanation = 'Geometric sequence: multiply by $ratio each time';
  }

  void _generateFibonacciSequence() {
    _currentSequence = [1, 1, 2, 3, 5];
    _correctAnswer = 8;
    _explanation =
        'Fibonacci sequence: each number is the sum of the previous two';
  }

  void _generateSquareSequence() {
    _currentSequence = [1, 4, 9, 16, 25];
    _correctAnswer = 36;
    _explanation = 'Square sequence: 1², 2², 3², 4², 5², 6²';
  }

  void _generatePrimeSequence() {
    final primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29];
    final startIndex = _random.nextInt(5);

    _currentSequence = primes.sublist(startIndex, startIndex + 5);
    _correctAnswer = primes[startIndex + 5];
    _explanation = 'Prime number sequence';
  }

  void _generateOptions() {
    _options = [_correctAnswer];

    while (_options.length < 4) {
      int option;
      if (_sequenceType == 'arithmetic') {
        option = _correctAnswer + (_random.nextInt(10) - 5);
      } else if (_sequenceType == 'geometric') {
        option = (_correctAnswer * (0.5 + _random.nextDouble())).round();
      } else {
        option = _correctAnswer + (_random.nextInt(20) - 10);
      }

      if (option > 0 && !_options.contains(option)) {
        _options.add(option);
      }
    }

    _options.shuffle(_random);
  }

  void _handleAnswer(int selectedAnswer) {
    final correct = selectedAnswer == _correctAnswer;
    _responses.add(correct);

    setState(() {
      _answeredCorrectly = correct;
      _showingResult = true;
    });

    if (correct) {
      addScore(100);
    }

    // Show result for 2 seconds, then continue
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showingResult = false;
        });

        _currentRound++;

        if (_currentRound >= totalRounds) {
          endGame();
        } else {
          _generateSequence();
        }
      }
    });
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

  @override
  void onGameEnded() {
    // Calculate accuracy and record session result for ELO rating
    final correctCount = _responses.where((r) => r).length;
    final accuracy = SafeMath.safeAccuracy(correctCount, totalRounds);
    recordSessionResult(accuracy: accuracy);
  }

  Widget _buildInstructions() {
    return ResponsiveWrapper(
      child: Padding(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.functions,
              size: ResponsiveUtils.getIconSize(context,
                  type: IconSizeType.xlarge),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            Text(
              'Number Sequence',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            Text(
              'Find the pattern in the number sequence and select the next number.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: ResponsiveUtils.getSpacing(context,
                    type: SpacingType.large)),
            Container(
              padding: ResponsiveUtils.getScreenPadding(context),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  _resultRow('Difficulty:',
                      widget.difficulty?.name.toUpperCase() ?? 'MEDIUM'),
                  _resultRow('Rounds:', '$totalRounds'),
                  _resultRow('Time Limit:', '${timeLimit}s'),
                ],
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getSpacing(context,
                    type: SpacingType.large)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.getSpacing(context),
                  ),
                ),
                child: Text(
                  'Start Game',
                  style: TextStyle(
                    fontSize: 18 * ResponsiveUtils.getFontScale(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
          ),

          Expanded(
            child: Padding(
              padding: ResponsiveUtils.getScreenPadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sequence display
                  Text(
                    'Find the pattern:',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: ResponsiveUtils.getSpacing(context)),

                  Container(
                    padding: ResponsiveUtils.getScreenPadding(context),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._currentSequence.map((number) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: 24 *
                                      ResponsiveUtils.getFontScale(context),
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '?',
                            style: TextStyle(
                              fontSize:
                                  24 * ResponsiveUtils.getFontScale(context),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      height: ResponsiveUtils.getSpacing(context,
                          type: SpacingType.large)),

                  // Options
                  Text(
                    'What comes next?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: ResponsiveUtils.getSpacing(context)),

                  Wrap(
                    spacing: ResponsiveUtils.getSpacing(context),
                    runSpacing: ResponsiveUtils.getSpacing(context),
                    children: _options
                        .map((option) => SizedBox(
                              width: (MediaQuery.of(context).size.width -
                                      ResponsiveUtils.getScreenPadding(context)
                                          .horizontal -
                                      ResponsiveUtils.getSpacing(context)) /
                                  2,
                              child: ElevatedButton(
                                onPressed: _showingResult
                                    ? null
                                    : () => _handleAnswer(option),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveUtils.getSpacing(context),
                                  ),
                                ),
                                child: Text(
                                  option.toString(),
                                  style: TextStyle(
                                    fontSize: 18 *
                                        ResponsiveUtils.getFontScale(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  if (_showingResult) ...[
                    SizedBox(
                        height: ResponsiveUtils.getSpacing(context,
                            type: SpacingType.large)),
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(
                          context,
                          type: SpacingType.small)),
                      decoration: BoxDecoration(
                        color: _answeredCorrectly
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _answeredCorrectly ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _answeredCorrectly
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _answeredCorrectly
                                    ? Colors.green
                                    : Colors.red,
                                size: ResponsiveUtils.getIconSize(context),
                              ),
                              SizedBox(
                                  width: ResponsiveUtils.getSpacing(context,
                                      type: SpacingType.small)),
                              Text(
                                _answeredCorrectly ? 'Correct!' : 'Incorrect',
                                style: TextStyle(
                                  fontSize: 18 *
                                      ResponsiveUtils.getFontScale(context),
                                  fontWeight: FontWeight.bold,
                                  color: _answeredCorrectly
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (!_answeredCorrectly) ...[
                            SizedBox(
                                height: ResponsiveUtils.getSpacing(context,
                                    type: SpacingType.small)),
                            Text(
                              'Correct answer: $_correctAnswer',
                              style: TextStyle(
                                fontSize:
                                    14 * ResponsiveUtils.getFontScale(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          SizedBox(
                              height: ResponsiveUtils.getSpacing(context,
                                  type: SpacingType.small)),
                          Text(
                            _explanation,
                            style: TextStyle(
                              fontSize:
                                  14 * ResponsiveUtils.getFontScale(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final correctAnswers = _responses.where((r) => r).length;
    final accuracy = _responses.isNotEmpty
        ? (correctAnswers / _responses.length) * 100
        : 0.0;

    return ResponsiveWrapper(
      child: Padding(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: ResponsiveUtils.getIconSize(context,
                  type: IconSizeType.xlarge),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            Text(
              CongratulationsUtils.getCompletionTitle(accuracy),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                CongratulationsUtils.getCompletionMessage(
                    accuracy, totalScore.toInt(), totalRounds),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getSpacing(context,
                    type: SpacingType.large)),
            Container(
              padding: ResponsiveUtils.getScreenPadding(context),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  _resultRow('Score:', '${totalScore.toInt()}'),
                  _resultRow('Accuracy:', '${accuracy.toStringAsFixed(1)}%'),
                  _resultRow(
                      'Correct:', '$correctAnswers/${_responses.length}'),
                  _resultRow('Time:', '${timeLimit - remainingTime}s'),
                ],
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getSpacing(context,
                    type: SpacingType.large)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getSpacing(context),
                      ),
                    ),
                    child: Text(
                      'Back to Games',
                      style: TextStyle(
                        fontSize: 16 * ResponsiveUtils.getFontScale(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentRound = 0;
                        _responses.clear();
                        _showingResult = false;
                      });
                      startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getSpacing(context),
                      ),
                    ),
                    child: Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 16 * ResponsiveUtils.getFontScale(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(context, type: SpacingType.small),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
