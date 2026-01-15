import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/models.dart';

/// Tracks used questions/patterns across all games to prevent repeats
class QuestionTracker {
  static const String _keyPrefix = 'used_questions_';
  static const int _maxStoredQuestions = 1000; // Limit storage size

  static QuestionTracker? _instance;
  static QuestionTracker get instance => _instance ??= QuestionTracker._();

  QuestionTracker._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the question tracker
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Get the storage key for a specific game
  String _getKey(GameId gameId) => '$_keyPrefix${gameId.name}';

  /// Get all used questions for a game
  Future<Set<String>> getUsedQuestions(GameId gameId) async {
    await initialize();
    final key = _getKey(gameId);
    final jsonList = _prefs.getStringList(key) ?? [];
    return jsonList.toSet();
  }

  /// Check if a question has been used
  Future<bool> isQuestionUsed(GameId gameId, String questionKey) async {
    final usedQuestions = await getUsedQuestions(gameId);
    return usedQuestions.contains(questionKey);
  }

  /// Mark a question as used
  Future<void> markQuestionUsed(GameId gameId, String questionKey) async {
    await initialize();
    final key = _getKey(gameId);
    final usedQuestions = await getUsedQuestions(gameId);

    usedQuestions.add(questionKey);

    // Limit storage size by removing oldest entries if needed
    final questionsList = usedQuestions.toList();
    if (questionsList.length > _maxStoredQuestions) {
      questionsList.removeRange(0, questionsList.length - _maxStoredQuestions);
    }

    await _prefs.setStringList(key, questionsList);
  }

  /// Mark multiple questions as used
  Future<void> markQuestionsUsed(
      GameId gameId, List<String> questionKeys) async {
    await initialize();
    final key = _getKey(gameId);
    final usedQuestions = await getUsedQuestions(gameId);

    usedQuestions.addAll(questionKeys);

    // Limit storage size
    final questionsList = usedQuestions.toList();
    if (questionsList.length > _maxStoredQuestions) {
      questionsList.removeRange(0, questionsList.length - _maxStoredQuestions);
    }

    await _prefs.setStringList(key, questionsList);
  }

  /// Clear all used questions for a game (useful for testing or reset)
  Future<void> clearUsedQuestions(GameId gameId) async {
    await initialize();
    final key = _getKey(gameId);
    await _prefs.remove(key);
  }

  /// Clear all used questions for all games
  Future<void> clearAllUsedQuestions() async {
    await initialize();
    for (final gameId in GameId.values) {
      await clearUsedQuestions(gameId);
    }
  }

  /// Get statistics about used questions
  Future<Map<GameId, int>> getUsageStatistics() async {
    final stats = <GameId, int>{};
    for (final gameId in GameId.values) {
      final usedQuestions = await getUsedQuestions(gameId);
      stats[gameId] = usedQuestions.length;
    }
    return stats;
  }
}

/// Helper class for generating unique question keys
class QuestionKeyGenerator {
  /// Generate a key for arithmetic questions
  static String arithmeticKey(int num1, int num2, String operator) {
    return 'arithmetic_${num1}_${operator}_$num2';
  }

  /// Generate a key for N-Back questions
  static String nBackKey(List<String> sequence) {
    return 'nback_${sequence.join('_')}';
  }

  /// Generate a key for Stroop questions
  static String stroopKey(String word, String color, bool isMatch) {
    return 'stroop_${word}_${color}_$isMatch';
  }

  /// Generate a key for spatial rotation questions
  static String spatialRotationKey(String shape, int rotation) {
    return 'spatial_${shape}_$rotation';
  }

  /// Generate a key for memory grid questions
  static String memoryGridKey(List<int> positions, int gridSize) {
    return 'memory_${gridSize}x${gridSize}_${positions.join('_')}';
  }

  /// Generate a key for trail connect questions
  static String trailConnectKey(List<String> sequence) {
    return 'trail_${sequence.join('_')}';
  }

  /// Generate a key for Go/No-Go questions
  static String goNoGoKey(String stimulus, bool isGo) {
    return 'gonogo_${stimulus}_$isGo';
  }

  /// Generate a key for color match questions
  static String colorMatchKey(List<String> colorSequence) {
    return 'colormatch_${colorSequence.join('_')}';
  }

  /// Generate a key for pattern matrix questions
  static String patternMatrixKey(List<List<bool>> pattern) {
    final flatPattern =
        pattern.expand((row) => row).map((b) => b ? '1' : '0').join('');
    return 'pattern_$flatPattern';
  }

  /// Generate a key for word chain questions
  static String wordChainKey(
      String startWord, String endWord, List<String> chain) {
    return 'wordchain_${startWord}_${endWord}_${chain.join('_')}';
  }

  /// Generate a key for color dominance questions
  static String colorDominanceKey(
      List<String> symbols, Map<String, int> counts) {
    final sortedSymbols = symbols..sort();
    final countsStr = sortedSymbols.map((s) => '$s:${counts[s]}').join('_');
    return 'colordominance_$countsStr';
  }

  /// Generate a generic key from any object
  static String genericKey(String prefix, Object data) {
    final dataStr = data.toString().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return '${prefix}_$dataStr';
  }
}

/// Mixin for games to easily integrate question tracking
mixin QuestionTrackingMixin {
  GameId get gameId;

  /// Check if a question has been used
  Future<bool> isQuestionUsed(String questionKey) async {
    return await QuestionTracker.instance.isQuestionUsed(gameId, questionKey);
  }

  /// Mark a question as used
  Future<void> markQuestionUsed(String questionKey) async {
    await QuestionTracker.instance.markQuestionUsed(gameId, questionKey);
  }

  /// Mark multiple questions as used
  Future<void> markQuestionsUsed(List<String> questionKeys) async {
    await QuestionTracker.instance.markQuestionsUsed(gameId, questionKeys);
  }

  /// Generate a unique question that hasn't been used
  Future<T> generateUniqueQuestion<T>(
    String Function(T) keyGenerator,
    T Function() questionGenerator, {
    int maxAttempts = 100,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final question = questionGenerator();
      final key = keyGenerator(question);

      if (!await isQuestionUsed(key)) {
        await markQuestionUsed(key);
        return question;
      }
    }

    // If we can't generate a unique question after maxAttempts,
    // return a question anyway (better than infinite loop)
    final question = questionGenerator();
    final key = keyGenerator(question);
    await markQuestionUsed(key);
    return question;
  }

  /// Generate multiple unique questions
  Future<List<T>> generateUniqueQuestions<T>(
    String Function(T) keyGenerator,
    T Function() questionGenerator,
    int count, {
    int maxAttempts = 100,
  }) async {
    final questions = <T>[];
    final usedKeys = <String>{};

    for (int i = 0; i < count; i++) {
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final question = questionGenerator();
        final key = keyGenerator(question);

        if (!await isQuestionUsed(key) && !usedKeys.contains(key)) {
          questions.add(question);
          usedKeys.add(key);
          break;
        }

        // If this is the last attempt, add the question anyway
        if (attempt == maxAttempts - 1) {
          questions.add(question);
          usedKeys.add(key);
        }
      }
    }

    // Mark all generated questions as used
    await markQuestionsUsed(usedKeys.toList());

    return questions;
  }
}
