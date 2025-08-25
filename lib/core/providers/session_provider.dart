import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/models.dart';
import '../utils/workout_planner.dart';
import '../utils/elo_rating.dart';
import 'game_configs_provider.dart';
import 'user_profile_provider.dart';

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref);
});

final todayPlanProvider = Provider<SessionPlan?>((ref) {
  final session = ref.watch(sessionProvider);
  return session.todayPlan;
});

final sessionResultsProvider = Provider<List<SessionResult>>((ref) {
  final box = Hive.box<SessionResult>('session_results');
  return box.values.toList();
});

class SessionState {
  final SessionPlan? todayPlan;
  final String? currentSessionId;
  final List<SessionResult> todayResults;
  final bool isSessionActive;
  
  SessionState({
    this.todayPlan,
    this.currentSessionId,
    this.todayResults = const [],
    this.isSessionActive = false,
  });
  
  SessionState copyWith({
    SessionPlan? todayPlan,
    String? currentSessionId,
    List<SessionResult>? todayResults,
    bool? isSessionActive,
  }) {
    return SessionState(
      todayPlan: todayPlan ?? this.todayPlan,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      todayResults: todayResults ?? this.todayResults,
      isSessionActive: isSessionActive ?? this.isSessionActive,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref ref;
  
  SessionNotifier(this.ref) : super(SessionState()) {
    _loadTodayPlan();
    _loadTodayResults();
  }
  
  void _loadTodayPlan() {
    final today = DateTime.now();
    final box = Hive.box<SessionPlan>('session_plans');
    
    SessionPlan? todayPlan;
    for (final plan in box.values) {
      if (_isSameDay(plan.date, today)) {
        todayPlan = plan;
        break;
      }
    }
    
    if (todayPlan == null) {
      _generateTodayPlan();
    } else {
      state = state.copyWith(todayPlan: todayPlan);
    }
  }
  
  void _loadTodayResults() {
    final today = DateTime.now();
    final box = Hive.box<SessionResult>('session_results');
    
    final todayResults = box.values
        .where((result) => _isSameDay(result.timestamp, today))
        .toList();
    
    state = state.copyWith(todayResults: todayResults);
  }
  
  Future<void> _generateTodayPlan() async {
    final profile = ref.read(userProfileProvider);
    final gameConfigs = ref.read(gameConfigsProvider);
    final allResults = ref.read(sessionResultsProvider);
    
    if (profile == null) return;
    
    final today = DateTime.now();
    final plan = WorkoutPlanner.generateDailyPlan(
      today,
      gameConfigs,
      allResults,
      profile.id,
    );
    
    final box = Hive.box<SessionPlan>('session_plans');
    await box.add(plan);
    
    state = state.copyWith(todayPlan: plan);
  }
  
  String startSession() {
    final sessionId = const Uuid().v4();
    state = state.copyWith(
      currentSessionId: sessionId,
      isSessionActive: true,
    );
    return sessionId;
  }
  
  Future<void> recordGameResult(SessionResult result) async {
    final box = Hive.box<SessionResult>('session_results');
    await box.add(result);
    
    // Update ELO rating
    final gameConfigsNotifier = ref.read(gameConfigsProvider.notifier);
    final config = gameConfigsNotifier.getConfig(result.gameId);
    
    if (config != null) {
      final performanceScore = EloRating.gamePerformanceToScore(
        result.accuracy,
        result.reactionTime,
      );
      
      final newRating = EloRating.updateRating(
        config.difficultyRating,
        1200.0, // Base opponent rating
        performanceScore,
      );
      
      await gameConfigsNotifier.updateDifficulty(result.gameId, newRating);
      await gameConfigsNotifier.updateHighScore(result.gameId, result.score);
    }
    
    // Update today's results
    final updatedResults = [...state.todayResults, result];
    state = state.copyWith(todayResults: updatedResults);
  }
  
  void endSession() {
    state = state.copyWith(
      currentSessionId: null,
      isSessionActive: false,
    );
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
