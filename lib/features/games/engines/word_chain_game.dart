import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/congratulations_utils.dart';
import '../../../core/constants/game_constants.dart';

class WordChainGame extends BaseGame {
  const WordChainGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<WordChainGame> createState() => _WordChainGameState();
}

class _WordChainGameState extends BaseGameState<WordChainGame> {
  late Random _random;

  int _currentRound = 0;

  final List<bool> _responses = [];
  double _totalScore = 0;

  final List<String> _wordChain = [];
  List<String> _options = [];
  int _correctOption = 0;

  final List<String> _categories = [
    'Animals',
    'Colors',
    'Food',
    'Countries',
    'Sports',
    'Professions'
  ];

  final Map<String, List<String>> _wordLists = {
    'Animals': [
      'Cat',
      'Dog',
      'Bird',
      'Fish',
      'Lion',
      'Tiger',
      'Bear',
      'Wolf',
      'Fox',
      'Deer'
    ],
    'Colors': [
      'Red',
      'Blue',
      'Green',
      'Yellow',
      'Purple',
      'Orange',
      'Pink',
      'Brown',
      'Black',
      'White'
    ],
    'Food': [
      'Apple',
      'Bread',
      'Cheese',
      'Pizza',
      'Pasta',
      'Rice',
      'Meat',
      'Fish',
      'Cake',
      'Soup'
    ],
    'Countries': [
      'USA',
      'Canada',
      'Mexico',
      'Brazil',
      'France',
      'Germany',
      'Italy',
      'Spain',
      'Japan',
      'China'
    ],
    'Sports': [
      'Soccer',
      'Basketball',
      'Tennis',
      'Golf',
      'Swimming',
      'Running',
      'Boxing',
      'Hockey',
      'Baseball',
      'Volleyball'
    ],
    'Professions': [
      'Doctor',
      'Teacher',
      'Engineer',
      'Artist',
      'Chef',
      'Pilot',
      'Nurse',
      'Lawyer',
      'Scientist',
      'Writer'
    ],
  };

  String _currentCategory = '';

  @override
  void initState() {
    super.initState();
    _random = Random();
    _generateRound();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getWordChainConfig(widget.difficulty!);
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
          Icon(Icons.link,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Word Chain',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Look at the sequence of words\n'
            '• All words belong to the same category\n'
            '• Choose the word that continues the pattern\n'
            '• Categories include animals, colors, food, etc.\n'
            '• Tests verbal reasoning and categorization',
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
                    'Time: ${remainingTime.toStringAsFixed(0)} s',
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Score: ${_totalScore.toInt()}',
                    style: TextStyle(
                      fontSize: 16 * ResponsiveUtils.getFontScale(context),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Game Area
          Expanded(
            child: Padding(
              padding:
                  ResponsiveUtils.getScreenPadding(context).copyWith(top: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final deviceType = ResponsiveUtils.getDeviceType(context);
                  final spacing = ResponsiveUtils.getSpacing(context);

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: spacing),

                        // Category
                        Text(
                          'Category: $_currentCategory',
                          style: TextStyle(
                            fontSize: switch (deviceType) {
                                  DeviceType.mobile => 18.0,
                                  DeviceType.tablet => 22.0,
                                  DeviceType.desktop => 26.0,
                                } *
                                ResponsiveUtils.getFontScale(context),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: spacing),

                        // Instruction
                        Text(
                          'Continue the word chain:',
                          style: TextStyle(
                            fontSize:
                                18 * ResponsiveUtils.getFontScale(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: spacing),

                        // Word chain
                        Container(
                          padding: EdgeInsets.all(spacing),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: ResponsiveUtils.getSpacing(context,
                                type: SpacingType.xs),
                            runSpacing: ResponsiveUtils.getSpacing(context,
                                type: SpacingType.xs),
                            children: [
                              ..._wordChain.map((word) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: spacing,
                                      vertical: ResponsiveUtils.getSpacing(
                                          context,
                                          type: SpacingType.xs),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      word,
                                      style: TextStyle(
                                        fontSize: 16 *
                                            ResponsiveUtils.getFontScale(
                                                context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: spacing,
                                  vertical: ResponsiveUtils.getSpacing(context,
                                      type: SpacingType.xs),
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  '?',
                                  style: TextStyle(
                                    fontSize: 16 *
                                        ResponsiveUtils.getFontScale(context),
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: spacing * 1.5),

                        // Options
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: switch (deviceType) {
                              DeviceType.mobile => 2.5,
                              DeviceType.tablet => 3.0,
                              DeviceType.desktop => 3.5,
                            },
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                              onPressed: () => _handleAnswer(index),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(spacing),
                                textStyle: TextStyle(
                                  fontSize: 16 *
                                      ResponsiveUtils.getFontScale(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Text(
                                _options[index],
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: spacing),
                      ],
                    ),
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
            CongratulationsUtils.getCompletionTitle(accuracy * 100),
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
                  accuracy * 100, _totalScore.toInt(), _currentRound),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _resultRow('Score', _totalScore.toInt().toString()),
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

  void _generateRound() {
    // Choose random category
    _currentCategory = _categories[_random.nextInt(_categories.length)];
    final words = _wordLists[_currentCategory]!;

    // Create chain of 3 words
    _wordChain.clear();
    final shuffledWords = List<String>.from(words)..shuffle(_random);

    for (int i = 0; i < 3; i++) {
      _wordChain.add(shuffledWords[i]);
    }

    // Correct answer is another word from same category
    final correctAnswer = shuffledWords[3];

    // Generate wrong options from other categories
    _options = [correctAnswer];
    while (_options.length < 4) {
      final wrongCategory = _categories[_random.nextInt(_categories.length)];
      if (wrongCategory != _currentCategory) {
        final wrongWords = _wordLists[wrongCategory]!;
        final wrongAnswer = wrongWords[_random.nextInt(wrongWords.length)];
        if (!_options.contains(wrongAnswer)) {
          _options.add(wrongAnswer);
        }
      }
    }

    _options.shuffle(_random);
    _correctOption = _options.indexOf(correctAnswer);

    setState(() {});
  }

  void _handleAnswer(int selectedOption) {
    final correct = selectedOption == _correctOption;
    _responses.add(correct);
    final score = correct ? 100 : 0;
    _totalScore += score;
    addScore(score); // Add to BaseGame's score tracking

    _currentRound++;

    if (_currentRound >= totalRounds) {
      _endGame();
    } else {
      _generateRound();
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
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
