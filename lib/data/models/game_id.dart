import 'package:flutter/material.dart';
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
  colorMatch,

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
      case GameId.colorMatch:
        return 'Color Match';
      case GameId.arithmeticSprint:
        return 'Arithmetic Sprint';
      case GameId.patternMatrix:
        return 'Pattern Matrix';
      case GameId.wordChain:
        return 'Word Chain';
      case GameId.visualSearch:
        return 'Color Dominance';
    }
  }

  IconData get icon {
    switch (this) {
      case GameId.speedTap:
        return Icons.touch_app;
      case GameId.stroopMatch:
        return Icons.psychology;
      case GameId.nBack:
        return Icons.memory;
      case GameId.spatialRotation:
        return Icons.rotate_right;
      case GameId.memoryGrid:
        return Icons.grid_4x4;
      case GameId.trailConnect:
        return Icons.timeline;
      case GameId.goNoGo:
        return Icons.traffic;
      case GameId.colorMatch:
        return Icons.palette;
      case GameId.arithmeticSprint:
        return Icons.calculate;
      case GameId.patternMatrix:
        return Icons.pattern;
      case GameId.wordChain:
        return Icons.link;
      case GameId.visualSearch:
        return Icons.grid_view;
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
      case GameId.colorMatch:
        return ['memory', 'attention'];
      case GameId.arithmeticSprint:
        return ['reasoning', 'speed'];
      case GameId.patternMatrix:
        return ['reasoning', 'spatial'];
      case GameId.wordChain:
        return ['verbal', 'flexibility'];
      case GameId.visualSearch:
        return ['attention', 'visual'];
    }
  }
}
