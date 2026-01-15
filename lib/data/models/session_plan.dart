import 'package:hive/hive.dart';
import 'game_id.dart';

part 'session_plan.g.dart';

@HiveType(typeId: 3)
class SessionPlan extends HiveObject {
  @HiveField(0)
  DateTime date;
  
  @HiveField(1)
  List<GameId> games;
  
  @HiveField(2)
  int seed;
  
  SessionPlan({
    required this.date,
    required this.games,
    required this.seed,
  });
}
