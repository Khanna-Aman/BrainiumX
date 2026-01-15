import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/models.dart';
import '../constants/game_constants.dart';
import '../providers/session_provider.dart';
import '../utils/question_tracker.dart';
import '../services/error_service.dart';
import '../../features/games/difficulty_selection_screen.dart'
    as difficulty_screen;

abstract class BaseGame extends ConsumerStatefulWidget {
  final GameId gameId;
  final difficulty_screen.DifficultyLevel? difficulty;

  const BaseGame({
    super.key,
    required this.gameId,
    this.difficulty,
  });
}

abstract class BaseGameState<T extends BaseGame> extends ConsumerState<T>
    with WidgetsBindingObserver, QuestionTrackingMixin {
  @override
  GameId get gameId => widget.gameId;

  // Common game state
  bool _gameStarted = false;
  bool _gameEnded = false;
  bool _gamePaused = false;

  // Timers that need cleanup
  final List<Timer> _activeTimers = [];

  // Game metrics
  int _currentRound = 0;
  int totalRounds = 5; // Made public to fix analyzer warning
  int _timeLimit = GameConstants.defaultTimeLimit;
  int _remainingTime = GameConstants.defaultTimeLimit;

  final List<int> _scores = [];
  double _totalScore = 0;

  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    configureDifficulty();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupAllTimers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _pauseGame();
        break;
      case AppLifecycleState.resumed:
        _resumeGame();
        break;
      case AppLifecycleState.detached:
        _cleanupAllTimers();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  // Enhanced timer management with safety checks
  Timer addTimer(Duration duration, VoidCallback callback) {
    final timer = Timer(duration, () {
      if (mounted && !_gameEnded) {
        try {
          callback();
        } catch (error, stackTrace) {
          debugPrint('Timer callback error: $error\n$stackTrace');
          // Log error but don't crash the app
          ErrorService.logError(error, stackTrace,
              context: 'Timer callback in ${widget.gameId.name}');
        }
      }
    });
    _activeTimers.add(timer);
    return timer;
  }

  Timer addPeriodicTimer(Duration duration, void Function(Timer) callback) {
    late Timer timer;
    timer = Timer.periodic(duration, (t) {
      if (!mounted || _gameEnded) {
        t.cancel();
        _activeTimers.remove(t);
        return;
      }

      if (!_gamePaused) {
        try {
          callback(t);
        } catch (error, stackTrace) {
          debugPrint('Periodic timer callback error: $error\n$stackTrace');
          ErrorService.logError(error, stackTrace,
              context: 'Periodic timer in ${widget.gameId.name}');
          t.cancel();
          _activeTimers.remove(t);
        }
      }
    });
    _activeTimers.add(timer);
    return timer;
  }

  void removeTimer(Timer timer) {
    _activeTimers.remove(timer);
    timer.cancel();
  }

  void _cleanupAllTimers() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  // Game lifecycle
  void _pauseGame() {
    if (!_gameStarted || _gameEnded || _gamePaused) return;

    setState(() {
      _gamePaused = true;
    });

    _gameTimer?.cancel();
    onGamePaused();
  }

  void _resumeGame() {
    if (!_gamePaused) return;

    setState(() {
      _gamePaused = false;
    });

    _startGameTimer();
    onGameResumed();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = addPeriodicTimer(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0 && !_gamePaused) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _endGame();
      }
    });
  }

  void startGame() {
    if (_gameStarted) return;

    setState(() {
      _gameStarted = true;
    });

    _startGameTimer();
    onGameStarted();
  }

  void endGame() {
    _endGame();
  }

  void _endGame() {
    if (_gameEnded) return;

    _cleanupAllTimers();
    setState(() {
      _gameEnded = true;
    });

    onGameEnded();
  }

  // Error handling
  Widget _buildErrorBoundary(Widget child) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error, stackTrace) {
          debugPrint('Game error: $error\n$stackTrace');
          return _buildErrorScreen(error);
        }
      },
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.toString()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  // Common UI builders
  Widget buildGameInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Round: ${_currentRound + 1}/$totalRounds'),
        Text('Time: ${_remainingTime}s'),
        Text('Score: ${_totalScore.toInt()}'),
      ],
    );
  }

  Widget buildPauseOverlay() {
    if (!_gamePaused) return const SizedBox.shrink();

    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause_circle, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Game Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Resume when you return to the app',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Abstract methods for subclasses
  void configureDifficulty();
  void onGameStarted() {}
  void onGamePaused() {}
  void onGameResumed() {}
  void onGameEnded() {}

  Widget buildStartScreen();
  Widget buildGameScreen();
  Widget buildEndScreen();

  @override
  Widget build(BuildContext context) {
    return _buildErrorBoundary(
      Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (!_gameStarted)
                buildStartScreen()
              else if (_gameEnded)
                buildEndScreen()
              else
                buildGameScreen(),
              buildPauseOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // Getters for subclasses
  bool get gameStarted => _gameStarted;
  bool get gameEnded => _gameEnded;
  bool get gamePaused => _gamePaused;
  int get currentRound => _currentRound;
  int get timeLimit => _timeLimit;
  int get remainingTime => _remainingTime;
  List<int> get scores => _scores;
  double get totalScore => _totalScore;

  // Setters for subclasses
  set timeLimit(int value) {
    _timeLimit = value;
    _remainingTime = value;
  }

  void addScore(int score) {
    _scores.add(score);
    _totalScore += score;
  }

  void recordSessionResult({double? accuracy, double? reactionTime}) {
    // Create a session result and record it
    try {
      final sessionNotifier = ref.read(sessionProvider.notifier);
      final sessionResult = SessionResult(
        sessionId: const Uuid().v4(),
        gameId: widget.gameId,
        score: _totalScore.toDouble(),
        accuracy: accuracy ?? 0.0,
        timestamp: DateTime.now(),
        reactionTime: reactionTime,
        difficultyBefore: null, // Will be set by session provider
        difficultyAfter: null, // Will be set by session provider
      );

      // Record the result which will update ratings and high scores
      sessionNotifier.recordGameResult(sessionResult);

      _endGame();
    } catch (error) {
      debugPrint('Error recording session result: $error');
      _endGame();
    }
  }

  void nextRound() {
    if (_currentRound + 1 >= totalRounds) {
      _endGame();
    } else {
      setState(() {
        _currentRound++;
      });
    }
  }

  // Accessibility helpers
  void announceToScreenReader(String message) {
    addTimer(GameConstants.semanticAnnouncementDelay, () {
      if (mounted) {
        // Screen reader announcement without audio
        // This is a placeholder for semantic announcements
      }
    });
  }

  Widget buildAccessibleButton({
    required String label,
    required VoidCallback? onPressed,
    required Widget child,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        height: GameConstants.minimumTouchTargetSize,
        child: child,
      ),
    );
  }

  Widget buildAccessibleGameElement({
    required String label,
    required Widget child,
    bool isInteractive = false,
    String? value,
    String? hint,
  }) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      button: isInteractive,
      child: child,
    );
  }
}
