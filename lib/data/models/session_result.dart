import 'package:hive/hive.dart';
import 'game_id.dart';

part 'session_result.g.dart';

@HiveType(typeId: 4)
class SessionResult extends HiveObject {
  @HiveField(0)
  String sessionId;
  
  @HiveField(1)
  GameId gameId;
  
  @HiveField(2)
  double score;
  
  @HiveField(3)
  double accuracy;
  
  @HiveField(4)
  DateTime timestamp;
  
  @HiveField(5)
  double? reactionTime;
  
  @HiveField(6)
  double? difficultyBefore;
  
  @HiveField(7)
  double? difficultyAfter;
  
  SessionResult({
    required this.sessionId,
    required this.gameId,
    required this.score,
    required this.accuracy,
    required this.timestamp,
    this.reactionTime,
    this.difficultyBefore,
    this.difficultyAfter,
  });
}
