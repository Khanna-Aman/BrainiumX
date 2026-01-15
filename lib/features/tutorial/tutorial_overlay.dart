import 'package:flutter/material.dart';
import '../../data/models/models.dart';

class TutorialOverlay extends StatefulWidget {
  final GameId gameId;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.gameId,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;
  late List<TutorialStep> _steps;

  @override
  void initState() {
    super.initState();
    _steps = _getTutorialSteps(widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep >= _steps.length) {
      return const SizedBox.shrink();
    }

    final step = _steps[_currentStep];

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  step.icon,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: _previousStep,
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox.shrink(),
                    Text('${_currentStep + 1} / ${_steps.length}'),
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(_currentStep == _steps.length - 1
                          ? 'Start Game'
                          : 'Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  List<TutorialStep> _getTutorialSteps(GameId gameId) {
    switch (gameId) {
      case GameId.speedTap:
        return [
          TutorialStep(
            icon: Icons.touch_app,
            title: 'Speed Tap Tutorial',
            description:
                'Test your reaction time by tapping as quickly as possible when the screen turns green.',
          ),
          TutorialStep(
            icon: Icons.timer,
            title: 'Wait for Green',
            description:
                'The screen will be gray. Wait patiently until it turns green, then tap immediately.',
          ),
          TutorialStep(
            icon: Icons.warning,
            title: 'Avoid False Starts',
            description:
                'Don\'t tap before the screen turns green! This counts as a false start and hurts your score.',
          ),
        ];

      case GameId.stroopMatch:
        return [
          TutorialStep(
            icon: Icons.psychology,
            title: 'Stroop Match Tutorial',
            description:
                'Test your ability to ignore conflicting information and focus on what matters.',
          ),
          TutorialStep(
            icon: Icons.color_lens,
            title: 'Focus on Color',
            description:
                'You\'ll see color words like "RED" or "BLUE". Focus on the COLOR of the text, not the word itself.',
          ),
          TutorialStep(
            icon: Icons.check_circle,
            title: 'Match or No Match',
            description:
                'Tap MATCH if the word meaning and color are the same. Tap NO MATCH if they\'re different.',
          ),
        ];

      case GameId.patternSequence:
        return [
          TutorialStep(
            icon: Icons.memory,
            title: 'N-Back Tutorial',
            description:
                'Train your working memory by remembering positions from previous steps.',
          ),
          TutorialStep(
            icon: Icons.grid_3x3,
            title: 'Watch the Grid',
            description:
                'Positions will light up one by one on a 3×3 grid. Pay close attention to the sequence.',
          ),
          TutorialStep(
            icon: Icons.compare_arrows,
            title: '2-Back Challenge',
            description:
                'Tap MATCH if the current position is the same as 2 steps back. Otherwise tap NO MATCH.',
          ),
        ];

      case GameId.memoryGrid:
        return [
          TutorialStep(
            icon: Icons.grid_4x4,
            title: 'Memory Grid Tutorial',
            description:
                'Test your spatial memory by remembering which squares light up.',
          ),
          TutorialStep(
            icon: Icons.visibility,
            title: 'Memorize Pattern',
            description:
                'Watch carefully as some squares in the grid light up blue for 2 seconds.',
          ),
          TutorialStep(
            icon: Icons.touch_app,
            title: 'Recall Pattern',
            description:
                'After the pattern disappears, tap all the squares that were highlighted.',
          ),
        ];

      default:
        return [
          TutorialStep(
            icon: Icons.help,
            title: '${gameId.displayName} Tutorial',
            description:
                'Follow the on-screen instructions to learn how to play this game.',
          ),
        ];
    }
  }
}

class TutorialStep {
  final IconData icon;
  final String title;
  final String description;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
