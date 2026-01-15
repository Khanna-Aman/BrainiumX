import '../utils/game_difficulty_config.dart';
import '../../features/games/difficulty_selection_screen.dart';

class ConfigCache {
  static final Map<String, GameDifficultyConfig> _cache = {};

  static GameDifficultyConfig getConfig(
    String gameId,
    DifficultyLevel difficulty,
    GameDifficultyConfig Function() factory,
  ) {
    final key = '${gameId}_${difficulty.name}';
    return _cache.putIfAbsent(key, factory);
  }

  static void clearCache() {
    _cache.clear();
  }
}
