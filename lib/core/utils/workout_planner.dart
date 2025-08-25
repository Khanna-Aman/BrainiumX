import 'dart:math';
import '../../data/models/models.dart';

class WorkoutPlanner {
  static const int gamesPerDay = 5;
  static const List<String> allDomains = [
    'attention',
    'processing_speed',
    'inhibition',
    'working_memory',
    'spatial',
    'reasoning',
    'verbal'
  ];
  
  static SessionPlan generateDailyPlan(
    DateTime date,
    List<GameConfig> gameConfigs,
    List<SessionResult> recentResults,
    String userId,
  ) {
    final random = Random(_generateSeed(userId, date));
    final availableGames = gameConfigs.where((config) => config.unlocked).toList();
    
    if (availableGames.length < gamesPerDay) {
      // If not enough games unlocked, repeat some
      final selectedGames = <GameId>[];
      for (int i = 0; i < gamesPerDay; i++) {
        selectedGames.add(availableGames[i % availableGames.length].gameId);
      }
      return SessionPlan(
        date: date,
        games: selectedGames,
        seed: _generateSeed(userId, date),
      );
    }
    
    // Get games played in last 48 hours
    final cutoff = date.subtract(const Duration(hours: 48));
    final recentlyPlayed = recentResults
        .where((result) => result.timestamp.isAfter(cutoff))
        .map((result) => result.gameId)
        .toSet();
    
    // Prefer games not played recently
    final preferredGames = availableGames
        .where((config) => !recentlyPlayed.contains(config.gameId))
        .toList();
    
    final selectedGames = <GameId>[];
    final usedDomains = <String>{};
    
    // Try to balance domains
    for (int i = 0; i < gamesPerDay; i++) {
      GameConfig? bestGame;
      
      // First try preferred games that add new domains
      for (final game in preferredGames) {
        if (selectedGames.contains(game.gameId)) continue;
        
        final gameDomains = game.gameId.domains;
        final newDomains = gameDomains.where((d) => !usedDomains.contains(d));
        
        if (newDomains.isNotEmpty) {
          bestGame = game;
          break;
        }
      }
      
      // If no preferred game adds new domains, pick any available
      bestGame ??= availableGames
          .where((game) => !selectedGames.contains(game.gameId))
          .toList()
          .isNotEmpty
          ? availableGames
              .where((game) => !selectedGames.contains(game.gameId))
              .toList()[random.nextInt(availableGames
                  .where((game) => !selectedGames.contains(game.gameId))
                  .length)]
          : availableGames[random.nextInt(availableGames.length)];
      
      selectedGames.add(bestGame.gameId);
      usedDomains.addAll(bestGame.gameId.domains);
    }
    
    // Shuffle the final list
    selectedGames.shuffle(random);
    
    return SessionPlan(
      date: date,
      games: selectedGames,
      seed: _generateSeed(userId, date),
    );
  }
  
  static int _generateSeed(String userId, DateTime date) {
    final dateStr = '${date.year}-${date.month}-${date.day}';
    return (userId + dateStr).hashCode;
  }
}
