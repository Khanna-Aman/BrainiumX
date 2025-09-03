import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/scoring_engine.dart';
import '../../../core/utils/game_difficulty_config.dart';
import '../difficulty_selection_screen.dart' as difficulty_screen;

class SpatialRotationGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final difficulty_screen.DifficultyLevel? difficulty;

  const SpatialRotationGame({super.key, required this.gameId, this.difficulty});

  @override
  ConsumerState<SpatialRotationGame> createState() =>
      _SpatialRotationGameState();
}

class _SpatialRotationGameState extends ConsumerState<SpatialRotationGame> {
  late Random _random;
  Timer? _gameTimer;

  bool _gameStarted = false;
  bool _gameEnded = false;

  int _currentTrial = 0;
  int _totalTrials = 15;
  int _timeLimit = 120;
  int _remainingTime = 120;

  List<bool> _responses = [];
  double _totalScore = 0;

  List<List<bool>> _originalShape = [];
  List<List<bool>> _rotatedShape = [];
  bool _isCorrectRotation = true;
  int _rotationAngle = 90;

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
          DifficultyConfigProvider.getSpatialRotationConfig(widget.difficulty!);
      _totalTrials = difficultyConfig.gameSpecific['trials'] as int;
      _timeLimit = difficultyConfig.timeLimit;
      _remainingTime = _timeLimit;
    }
    // If no difficulty specified, use default values (already set)
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
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
    return Column(
      children: [
        // HUD
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trial: ${_currentTrial + 1}/$_totalTrials',
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
        ),

        // Game Area
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Are these the same shape?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShapeGrid(_originalShape, 'Original'),
                  const Icon(Icons.arrow_forward, size: 32),
                  _buildShapeGrid(_rotatedShape, 'Rotated'),
                ],
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleResponse(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('SAME', style: TextStyle(fontSize: 18)),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleResponse(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child:
                        const Text('DIFFERENT', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShapeGrid(List<List<bool>> shape, String label) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 120,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              final row = index ~/ 4;
              final col = index % 4;
              final isActive = row < shape.length &&
                  col < shape[row].length &&
                  shape[row][col];

              return Container(
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue : Colors.grey[300],
                  border: Border.all(color: Colors.black, width: 1),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final accuracy = _responses.where((r) => r).length / _totalTrials;

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
                  _ResultRow('Score', _totalScore.toInt().toString()),
                  _ResultRow('Accuracy', '${(accuracy * 100).toInt()}%'),
                  _ResultRow('Trials Completed', '$_currentTrial'),
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

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0 || _currentTrial >= _totalTrials) {
        _endGame();
      }
    });

    _generateShapes();
  }

  void _generateShapes() {
    // Generate a random 4x4 shape
    _originalShape =
        List.generate(4, (i) => List.generate(4, (j) => _random.nextBool()));

    // Decide if this should be a correct rotation or different shape
    _isCorrectRotation = _random.nextBool();

    if (_isCorrectRotation) {
      // Rotate the original shape
      _rotationAngle = [90, 180, 270][_random.nextInt(3)];
      _rotatedShape = _rotateShape(_originalShape, _rotationAngle);
    } else {
      // Generate a completely different shape
      _rotatedShape =
          List.generate(4, (i) => List.generate(4, (j) => _random.nextBool()));
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
    _totalScore += ScoringEngine.calculateSpatialRotationScore(correct);

    _currentTrial++;

    if (_currentTrial >= _totalTrials) {
      _endGame();
    } else {
      _generateShapes();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();

    setState(() {
      _gameEnded = true;
    });

    final accuracy = _responses.where((r) => r).length / _totalTrials;

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

  Widget _ResultRow(String label, String value) {
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
