import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/utils/difficulty_manager.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../difficulty_selection_screen.dart' as difficulty_screen;

class MemoryGridGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final difficulty_screen.DifficultyLevel? difficulty;

  const MemoryGridGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<MemoryGridGame> createState() => _MemoryGridGameState();
}

class _MemoryGridGameState extends ConsumerState<MemoryGridGame> {
  late Random _random;
  Timer? _gameTimer;
  Timer? _phaseTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;
  bool _showingPattern = false;
  bool _recallPhase = false;

  int _currentRound = 0;
  int _totalRounds = 8;
  int _timeLimit = 120;
  int _remainingTime = 120;
  int _gridSize = 4;

  List<bool> _responses = [];
  double _totalScore = 0;

  List<int> _targetCells = [];
  List<int> _selectedCells = [];

  @override
  void initState() {
    super.initState();
    _random = Random();
    _configureDifficulty();
  }

  void _configureDifficulty() {
    if (widget.difficulty != null) {
      // Use difficulty-based configuration
      final difficultyConfig =
          DifficultyConfigProvider.getMemoryGridConfig(widget.difficulty!);
      _totalRounds = difficultyConfig.rounds;
      _timeLimit = difficultyConfig.timeLimit;
      _gridSize = difficultyConfig.gameSpecific['gridSize'] as int;
      _remainingTime = _timeLimit;
    } else {
      // Fallback to rating-based configuration
      final gameConfigs = ref.read(gameConfigsProvider);
      final config = gameConfigs.firstWhere((c) => c.gameId == widget.gameId);
      final rating = config.difficultyRating;

      // Use the new difficulty manager
      final difficultyConfig = DifficultyManager.getMemoryGridConfig(rating);

      _totalRounds = difficultyConfig.totalRounds;
      _timeLimit = difficultyConfig.timeLimit;
      _gridSize = difficultyConfig.gridSize;
      _remainingTime = _timeLimit;
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildInstructions();
    }

    if (_gameEnded) {
      return _buildResults();
    }

    return _buildGameArea();
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
          Text(
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
            style: const TextStyle(fontSize: 16),
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
    return Column(
      children: [
        // HUD
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Round: ${_currentRound + 1}/$_totalRounds',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Time: $_remainingTime s',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Score: ${_totalScore.toInt()}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _showingPattern
                    ? 'Memorize the pattern...'
                    : _recallPhase
                        ? 'Tap the squares you remember'
                        : 'Get ready...',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Game Area
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                margin: const EdgeInsets.all(20),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _gridSize * _gridSize,
                  itemBuilder: (context, index) {
                    final isTarget = _targetCells.contains(index);
                    final isSelected = _selectedCells.contains(index);

                    Color color =
                        Theme.of(context).colorScheme.surfaceContainerHighest;
                    if (_showingPattern && isTarget) {
                      color = Theme.of(context).colorScheme.primary;
                    } else if (_recallPhase && isSelected) {
                      color = Theme.of(context).colorScheme.tertiary;
                    }

                    return GestureDetector(
                      onTap: _recallPhase ? () => _handleCellTap(index) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Always show button area to prevent layout shift
        Container(
          height: 80, // Fixed height to prevent shifting
          padding: const EdgeInsets.all(16),
          child: _recallPhase
              ? ElevatedButton(
                  onPressed: _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Submit', style: TextStyle(fontSize: 18)),
                )
              : const SizedBox(), // Empty space when not in recall phase
        ),
      ],
    );
  }

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / _totalRounds;
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
    setState(() {
      _gameStarted = true;
      _remainingTime = _timeLimit;
    });

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0 || _currentRound >= _totalRounds) {
        _endGame();
      }
    });

    _startRound();
  }

  void _startRound() {
    // Get difficulty configuration
    final gameConfigs = ref.read(gameConfigsProvider);
    final config = gameConfigs.firstWhere((c) => c.gameId == widget.gameId);
    final rating = config.difficultyRating;
    final difficultyConfig = DifficultyManager.getMemoryGridConfig(rating);

    // Calculate number of targets based on difficulty and round progression
    final progressRatio = _currentRound / _totalRounds;
    final targetRange =
        difficultyConfig.maxTargets - difficultyConfig.startingTargets;
    final numTargets = difficultyConfig.startingTargets +
        (targetRange * progressRatio).round();

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

    // Show pattern for 2 seconds
    _phaseTimer = Timer(const Duration(seconds: 2), () {
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
    _totalScore += ScoringEngine.calculateMemoryGridScore(correct);

    _currentRound++;

    if (_currentRound >= _totalRounds) {
      _endGame();
    } else {
      _startRound();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    // Record result
    final accuracy = _responses.where((r) => r).length / _totalRounds;

    final result = SessionResult(
      sessionId:
          ref.read(sessionProvider).currentSessionId ?? const Uuid().v4(),
      gameId: widget.gameId,
      score: _totalScore,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );

    ref.read(sessionProvider.notifier).recordGameResult(result);
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

  (String, String) _getCongratulationsMessage(double accuracy) {
    if (accuracy >= 0.9) {
      return (
        'Outstanding! 🌟',
        'Your memory is incredible! You\'re a true champion!'
      );
    } else if (accuracy >= 0.8) {
      return (
        'Excellent Work! 🎉',
        'Amazing memory skills! You\'re getting really good at this!'
      );
    } else if (accuracy >= 0.7) {
      return (
        'Great Job! 👏',
        'Your memory is improving! Keep up the fantastic work!'
      );
    } else if (accuracy >= 0.6) {
      return (
        'Well Done! 💪',
        'Good effort! Your memory skills are developing nicely!'
      );
    } else if (accuracy >= 0.5) {
      return (
        'Nice Try! 🎯',
        'You\'re learning! Every attempt makes your memory stronger!'
      );
    } else {
      return (
        'Keep Going! 🚀',
        'Practice makes perfect! Your memory will improve with each game!'
      );
    }
  }
}
