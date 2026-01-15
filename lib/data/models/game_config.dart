import 'package:hive/hive.dart';
import 'game_id.dart';

part 'game_config.g.dart';

@HiveType(typeId: 2)
class GameConfig extends HiveObject {
  @HiveField(0)
  GameId gameId;
  
  @HiveField(1)
  bool unlocked;
  
  @HiveField(2)
  double difficultyRating;
  
  @HiveField(3)
  double highScore;
  
  GameConfig({
    required this.gameId,
    this.unlocked = true,
    this.difficultyRating = 1200.0,
    this.highScore = 0.0,
  });
}
