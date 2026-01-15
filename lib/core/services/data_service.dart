import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/models.dart';
import '../constants/game_constants.dart';

class DataService {
  // Input validation methods
  static UserProfile? _parseUserProfile(Map<String, dynamic>? data) {
    if (data == null) return null;

    try {
      final id = data['id'] as String?;
      if (id == null || id.isEmpty) return null;

      final displayName = data['displayName'] as String? ?? 'User';
      final dobString = data['dob'] as String?;
      DateTime? dob;

      if (dobString != null && dobString.isNotEmpty) {
        try {
          dob = DateTime.parse(dobString);
          // Validate reasonable date range (not in future, not too old)
          final now = DateTime.now();
          if (dob.isAfter(now) || dob.isBefore(DateTime(1900))) {
            dob = null;
          }
        } catch (e) {
          dob = null; // Invalid date format
        }
      }

      final preferredTheme = data['preferredTheme'] as String? ?? 'default';

      return UserProfile(
        id: id,
        displayName: displayName,
        dob: dob,
        preferredTheme: preferredTheme,
      );
    } catch (e) {
      return null; // Any parsing error returns null
    }
  }

  static GameConfig? _parseGameConfig(Map<String, dynamic>? data) {
    if (data == null) return null;

    try {
      final gameIdString = data['gameId'] as String?;
      if (gameIdString == null || gameIdString.isEmpty) return null;

      // Find matching GameId enum
      GameId? gameId;
      try {
        gameId = GameId.values.firstWhere((g) => g.name == gameIdString);
      } catch (e) {
        return null; // Invalid game ID
      }

      final unlocked = data['unlocked'] as bool? ?? true;
      final difficultyRating = SafeMath.safeClamp(
              (data['difficultyRating'] as num?)?.toInt() ?? 1200, 800, 2400)
          .toDouble();
      final highScore = SafeMath.safeClamp(
              (data['highScore'] as num?)?.toInt() ?? 0, 0, 1000000)
          .toDouble();

      return GameConfig(
        gameId: gameId,
        unlocked: unlocked,
        difficultyRating: difficultyRating,
        highScore: highScore,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String> exportData() async {
    final data = <String, dynamic>{};

    // Export user profile
    final userProfileBox = Hive.box<UserProfile>('user_profile');
    if (userProfileBox.isNotEmpty) {
      final profile = userProfileBox.values.first;
      data['userProfile'] = {
        'id': profile.id,
        'displayName': profile.displayName,
        'dob': profile.dob?.toIso8601String(),
        'preferredTheme': profile.preferredTheme,
      };
    }

    // Export game configs
    final gameConfigsBox = Hive.box<GameConfig>('game_configs');
    data['gameConfigs'] = gameConfigsBox.values
        .map((config) => {
              'gameId': config.gameId.name,
              'unlocked': config.unlocked,
              'difficultyRating': config.difficultyRating,
              'highScore': config.highScore,
            })
        .toList();

    // Export session results
    final sessionResultsBox = Hive.box<SessionResult>('session_results');
    data['sessionResults'] = sessionResultsBox.values
        .map((result) => {
              'sessionId': result.sessionId,
              'gameId': result.gameId.name,
              'score': result.score,
              'accuracy': result.accuracy,
              'timestamp': result.timestamp.toIso8601String(),
              'reactionTime': result.reactionTime,
              'difficultyBefore': result.difficultyBefore,
              'difficultyAfter': result.difficultyAfter,
            })
        .toList();

    // Export session plans
    final sessionPlansBox = Hive.box<SessionPlan>('session_plans');
    data['sessionPlans'] = sessionPlansBox.values
        .map((plan) => {
              'date': plan.date.toIso8601String(),
              'games': plan.games.map((g) => g.name).toList(),
              'seed': plan.seed,
            })
        .toList();

    data['exportDate'] = DateTime.now().toIso8601String();
    data['version'] = '1.0.0';

    return jsonEncode(data);
  }

  static Future<void> shareData() async {
    try {
      final jsonData = await exportData();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/brainiumx_backup.json');
      await file.writeAsString(jsonData);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'BrainiumX Data Backup',
        subject: 'My BrainiumX Progress Data',
      );
    } catch (e) {
      throw Exception('Failed to share data: $e');
    }
  }

  static Future<bool> importData(String jsonData) async {
    try {
      // Validate JSON format
      if (jsonData.isEmpty) {
        throw Exception('Empty data provided');
      }

      final data = jsonDecode(jsonData) as Map<String, dynamic>;

      // Validate data structure
      if (!data.containsKey('version')) {
        throw Exception('Invalid backup file format - missing version');
      }

      // Clear existing data
      await clearAllData();

      // Import user profile with validation
      if (data.containsKey('userProfile')) {
        final profileData = data['userProfile'] as Map<String, dynamic>?;
        final profile = _parseUserProfile(profileData);

        if (profile != null) {
          final userProfileBox = Hive.box<UserProfile>('user_profile');
          await userProfileBox.add(profile);
        }
      }

      // Import game configs with validation
      if (data.containsKey('gameConfigs')) {
        final gameConfigsBox = Hive.box<GameConfig>('game_configs');
        final configsData = data['gameConfigs'];

        if (configsData is List) {
          for (final configData in configsData) {
            if (configData is Map<String, dynamic>) {
              final config = _parseGameConfig(configData);
              if (config != null) {
                await gameConfigsBox.add(config);
              }
            }
          }
        }
      }

      // Import session results
      if (data.containsKey('sessionResults')) {
        final sessionResultsBox = Hive.box<SessionResult>('session_results');
        final resultsData = data['sessionResults'] as List<dynamic>;

        for (final resultData in resultsData) {
          final gameId = GameId.values.firstWhere(
            (g) => g.name == resultData['gameId'],
            orElse: () => GameId.speedTap,
          );

          final result = SessionResult(
            sessionId: resultData['sessionId'],
            gameId: gameId,
            score: (resultData['score'] ?? 0.0).toDouble(),
            accuracy: (resultData['accuracy'] ?? 0.0).toDouble(),
            timestamp: DateTime.parse(resultData['timestamp']),
            reactionTime: resultData['reactionTime']?.toDouble(),
            difficultyBefore: resultData['difficultyBefore']?.toDouble(),
            difficultyAfter: resultData['difficultyAfter']?.toDouble(),
          );

          await sessionResultsBox.add(result);
        }
      }

      // Import session plans
      if (data.containsKey('sessionPlans')) {
        final sessionPlansBox = Hive.box<SessionPlan>('session_plans');
        final plansData = data['sessionPlans'] as List<dynamic>;

        for (final planData in plansData) {
          final games = (planData['games'] as List<dynamic>)
              .map((g) => GameId.values.firstWhere(
                    (gameId) => gameId.name == g,
                    orElse: () => GameId.speedTap,
                  ))
              .toList();

          final plan = SessionPlan(
            date: DateTime.parse(planData['date']),
            games: games,
            seed: planData['seed'] ?? 0,
          );

          await sessionPlansBox.add(plan);
        }
      }

      return true;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  static Future<void> clearAllData() async {
    await Hive.box<UserProfile>('user_profile').clear();
    await Hive.box<GameConfig>('game_configs').clear();
    await Hive.box<SessionResult>('session_results').clear();
    await Hive.box<SessionPlan>('session_plans').clear();
  }

  static Future<Map<String, int>> getDataStats() async {
    return {
      'userProfiles': Hive.box<UserProfile>('user_profile').length,
      'gameConfigs': Hive.box<GameConfig>('game_configs').length,
      'sessionResults': Hive.box<SessionResult>('session_results').length,
      'sessionPlans': Hive.box<SessionPlan>('session_plans').length,
    };
  }
}
