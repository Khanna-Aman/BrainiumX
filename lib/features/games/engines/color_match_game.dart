import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../core/utils/question_tracker.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../../../core/utils/object_pool.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/base/base_game.dart';
import '../../../core/utils/responsive_utils.dart';

class ColorMatchGame extends BaseGame {
  const ColorMatchGame({super.key, required super.gameId, super.difficulty});

  @override
  ConsumerState<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends BaseGameState<ColorMatchGame> {
  late Random _random;
  Timer? _sequenceTimer;

  bool _showingSequence = false;
  bool _acceptingInput = false;
  bool _showingResult = false;
  int _sequenceIndex = 0;

  List<Color> _sequence = [];
  List<Color> _userSequence = [];
  bool _answeredCorrectly = false;

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _random = Random();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    if (_sequence.isNotEmpty) {
      ColorPool.releaseSequence(_sequence);
    }
    if (_userSequence.isNotEmpty) {
      ColorPool.releaseSequence(_userSequence);
    }
    super.dispose();
  }

  @override
  void configureDifficulty() {
    if (widget.difficulty != null) {
      final difficultyConfig =
          DifficultyConfigProvider.getColorMatchConfig(widget.difficulty!);
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
    _sequenceTimer?.cancel();
  }

  @override
  void onGameResumed() {
    if (_showingSequence) {
      _showSequence();
    }
  }

  // This method is now handled by BaseGame
  // @override
  // Widget build(BuildContext context) is in BaseGame

  @override
  Widget buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.gameId.icon,
            size: GameConstants.iconSize * 1.5,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Color Match',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Watch the sequence of colors and repeat it back in the exact same order.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: startGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Start Game', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildGameScreen() {
    return ResponsiveWrapper(
      child: Padding(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Column(
          children: [
            buildGameInfo(),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            if (_showingResult)
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                decoration: BoxDecoration(
                  color: _answeredCorrectly ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _answeredCorrectly ? 'Correct!' : 'Incorrect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24 * ResponsiveUtils.getFontScale(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _showingSequence
                      ? 'Watch the sequence'
                      : _acceptingInput
                          ? 'Repeat the sequence'
                          : 'Get ready...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize! *
                                ResponsiveUtils.getFontScale(context),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gridSize = ResponsiveUtils.getGameGridSize(context);
                  final spacing = ResponsiveUtils.getSpacing(context,
                      type: SpacingType.small);

                  // Ensure grid fits in available space
                  final maxGridSize =
                      constraints.maxHeight.clamp(200.0, gridSize);

                  return Center(
                    child: SizedBox(
                      width: maxGridSize,
                      height: maxGridSize,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                        itemCount: _colors.length,
                        itemBuilder: (context, index) {
                          final color = _colors[index];
                          final isHighlighted = _showingSequence &&
                              _sequenceIndex > 0 &&
                              _sequenceIndex <= _sequence.length &&
                              _sequence[_sequenceIndex - 1] == color;

                          return GestureDetector(
                            onTap: _acceptingInput
                                ? () => _selectColor(color)
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isHighlighted
                                      ? Colors.white
                                      : Colors.black26,
                                  width: isHighlighted ? 6 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: isHighlighted ? 12 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_acceptingInput) ...[
              Text(
                'Selected: ${_userSequence.length}/${_sequence.length}',
                style: TextStyle(
                  fontSize: 16 * ResponsiveUtils.getFontScale(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.getSpacing(context,
                      type: SpacingType.small)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getSpacing(context,
                            type: SpacingType.xs),
                      ),
                      child: SizedBox(
                        height: ResponsiveUtils.getButtonHeight(context),
                        child: ElevatedButton(
                          onPressed: _userSequence.isNotEmpty
                              ? () {
                                  setState(() {
                                    _userSequence.removeLast();
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(
                              fontSize:
                                  16 * ResponsiveUtils.getFontScale(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Undo'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getSpacing(context,
                            type: SpacingType.xs),
                      ),
                      child: SizedBox(
                        height: ResponsiveUtils.getButtonHeight(context),
                        child: ElevatedButton(
                          onPressed: _userSequence.length == _sequence.length
                              ? _submitAnswer
                              : null,
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(
                              fontSize:
                                  16 * ResponsiveUtils.getFontScale(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget buildEndScreen() {
    final accuracy =
        scores.where((score) => score > 0).length / totalRounds * 100;

    return Center(
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
    );
  }

  void _generateRound() async {
    _sequenceTimer?.cancel();

    // Release previous sequences to pool
    if (_sequence.isNotEmpty) {
      ColorPool.releaseSequence(_sequence);
    }
    if (_userSequence.isNotEmpty) {
      ColorPool.releaseSequence(_userSequence);
    }

    // Get new sequences from pool
    _sequence = ColorPool.getSequence();
    _userSequence = ColorPool.getSequence();

    _showingSequence = false;
    _acceptingInput = false;
    _showingResult = false;
    _sequenceIndex = 0;

    final sequenceLength =
        GameConstants.minSequenceLength + (currentRound ~/ 2);

    // Generate unique sequence using question tracking
    final colorSequence = await generateUniqueQuestion<List<Color>>(
      (sequence) => QuestionKeyGenerator.colorMatchKey(
        sequence.map((c) => c.toARGB32().toString()).toList(),
      ),
      () {
        final sequence = <Color>[];
        for (int i = 0; i < sequenceLength; i++) {
          sequence.add(_colors[_random.nextInt(_colors.length)]);
        }
        return sequence;
      },
    );

    _sequence.addAll(colorSequence);

    setState(() {});

    Timer(GameConstants.longPause, () {
      if (mounted && !gamePaused) _showSequence();
    });
  }

  void _showSequence() {
    if (gamePaused) return;

    setState(() {
      _showingSequence = true;
      _sequenceIndex = 0;
    });

    _sequenceTimer = Timer.periodic(GameConstants.sequenceDelay, (timer) {
      if (gamePaused) {
        timer.cancel();
        return;
      }

      setState(() {
        _sequenceIndex++;
      });

      if (_sequenceIndex >= _sequence.length) {
        timer.cancel();
        Timer(GameConstants.briefPause, () {
          if (mounted && !gamePaused) {
            setState(() {
              _showingSequence = false;
              _acceptingInput = true;
            });
          }
        });
      }
    });
  }

  void _selectColor(Color color) {
    if (!_acceptingInput ||
        _userSequence.length >= _sequence.length ||
        gamePaused) {
      return;
    }

    setState(() {
      _userSequence.add(color);
    });
  }

  void _submitAnswer() {
    if (_userSequence.length != _sequence.length || gamePaused) return;

    _answeredCorrectly = true;
    for (int i = 0; i < _sequence.length; i++) {
      if (_userSequence[i] != _sequence[i]) {
        _answeredCorrectly = false;
        break;
      }
    }

    final score = _answeredCorrectly ? 100 : 0;
    addScore(score);

    setState(() {
      _acceptingInput = false;
      _showingResult = true;
    });

    Timer(GameConstants.resultDisplayDuration, () {
      if (mounted && !gamePaused) {
        nextRound();
        if (!gameEnded) {
          _generateRound();
        }
      }
    });
  }

  @override
  void onGameEnded() {
    // Calculate accuracy and record session result for ELO rating
    final correctCount = scores.where((s) => s > 0).length;
    final accuracy = SafeMath.safeAccuracy(correctCount, totalRounds);
    recordSessionResult(accuracy: accuracy);
  }
}
