import 'package:hive/hive.dart';

part 'game_id.g.dart';

@HiveType(typeId: 0)
enum GameId {
  @HiveField(0)
  speedTap,
  
  @HiveField(1)
  stroopMatch,
  
  @HiveField(2)
  nBack,
  
  @HiveField(3)
  spatialRotation,
  
  @HiveField(4)
  memoryGrid,
  
  @HiveField(5)
  trailConnect,
  
  @HiveField(6)
  goNoGo,
  
  @HiveField(7)
  symbolSearch,
  
  @HiveField(8)
  arithmeticSprint,
  
  @HiveField(9)
  patternMatrix,
  
  @HiveField(10)
  wordChain,
  
  @HiveField(11)
  visualSearch,
}

extension GameIdExtension on GameId {
  String get displayName {
    switch (this) {
      case GameId.speedTap:
        return 'Speed Tap';
      case GameId.stroopMatch:
        return 'Stroop Match';
      case GameId.nBack:
        return 'N-Back';
      case GameId.spatialRotation:
        return 'Spatial Rotation';
      case GameId.memoryGrid:
        return 'Memory Grid';
      case GameId.trailConnect:
        return 'Trail Connect';
      case GameId.goNoGo:
        return 'Go/No-Go';
      case GameId.symbolSearch:
        return 'Symbol Search';
      case GameId.arithmeticSprint:
        return 'Arithmetic Sprint';
      case GameId.patternMatrix:
        return 'Pattern Matrix';
      case GameId.wordChain:
        return 'Word Chain';
      case GameId.visualSearch:
        return 'Visual Search';
    }
  }
  
  List<String> get domains {
    switch (this) {
      case GameId.speedTap:
        return ['speed', 'attention'];
      case GameId.stroopMatch:
        return ['inhibition', 'attention'];
      case GameId.nBack:
        return ['memory', 'attention'];
      case GameId.spatialRotation:
        return ['spatial', 'reasoning'];
      case GameId.memoryGrid:
        return ['memory'];
      case GameId.trailConnect:
        return ['attention', 'speed'];
      case GameId.goNoGo:
        return ['inhibition', 'attention'];
      case GameId.symbolSearch:
        return ['attention', 'speed'];
      case GameId.arithmeticSprint:
        return ['reasoning', 'speed'];
      case GameId.patternMatrix:
        return ['reasoning', 'spatial'];
      case GameId.wordChain:
        return ['verbal', 'flexibility'];
      case GameId.visualSearch:
        return ['attention', 'speed'];
    }
  }
}
