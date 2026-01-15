import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/constants/game_constants.dart';

class StroopMatchGame extends BaseGame {
  const StroopMatchGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<StroopMatchGame> createState() => _StroopMatchGameState();
}

class _StroopMatchGameState extends BaseGameState<StroopMatchGame> {
  late Random _random;

  int _currentTrial = 0;

  final List<bool> _responses = [];
  double _totalScore = 0;

  String _currentWord = '';
  Color _currentColor = Colors.red;
  bool _isCongruent = true;

  final List<String> _colorWords = ['RED', 'BLUE', 'GREEN', 'YELLOW'];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];

  @override
  void initState() {
    super.initState();
    _random = Random();
    _generateStimulus();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getStroopMatchConfig(widget.difficulty!);
      totalRounds = difficultyConfig.rounds;
      timeLimit = difficultyConfig.timeLimit;
    }
  }

  @override
  void onGameStarted() {
    _generateStimulus();
  }

  @override
  void onGamePaused() {
    // Pause any timers if needed
  }

  @override
  void onGameResumed() {
    // Resume any timers if needed
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
          Icon(Icons.psychology,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Stroop Match',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• You will see color words (RED, BLUE, etc.)\n'
            '• The word color may match or not match the text\n'
            '• Tap MATCH if the word and color are the same\n'
            '• Tap NO MATCH if they are different\n'
            '• Ignore the word meaning, focus on the color!',
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
                    'Time: ${remainingTime.toStringAsFixed(0)} s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Score: ${_totalScore.toInt()}',
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
                        'What color is this word?',
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

                      // Word display
                      Container(
                        padding: EdgeInsets.all(spacing * 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _currentWord,
                          style: TextStyle(
                            fontSize: switch (deviceType) {
                                  DeviceType.mobile => 48.0,
                                  DeviceType.tablet => 64.0,
                                  DeviceType.desktop => 80.0,
                                } *
                                ResponsiveUtils.getFontScale(context),
                            fontWeight: FontWeight.bold,
                            color: _currentColor,
                          ),
                        ),
                      ),

                      SizedBox(height: spacing * 3),

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
                                  child: const Text('MATCH'),
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
                                  child: const Text('NO MATCH'),
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

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / totalRounds;

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
                  _resultRow('Score', _totalScore.toInt().toString()),
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

  void _generateStimulus() {
    final wordIndex = _random.nextInt(_colorWords.length);
    final colorIndex = _random.nextInt(_colors.length);

    setState(() {
      _currentWord = _colorWords[wordIndex];
      _currentColor = _colors[colorIndex];
      _isCongruent = wordIndex == colorIndex;
    });
  }

  void _handleResponse(bool userSaysMatch) {
    final correct = userSaysMatch == _isCongruent;

    _responses.add(correct);
    final score = correct ? 100 : 0;
    _totalScore += score;
    addScore(score); // Add to BaseGame's score tracking

    _currentTrial++;

    if (_currentTrial >= totalRounds) {
      _endGame();
    } else {
      _generateStimulus();
    }
  }

  void _endGame() {
    endGame();
  }

  @override
  void onGameEnded() {
    // Calculate accuracy and record session result for ELO rating
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
