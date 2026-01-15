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
  patternSequence,

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
  focusShift,

  @HiveField(10)
  wordChain,

  @HiveField(11)
  colorDominance,
}

extension GameIdExtension on GameId {
  String get displayName {
    switch (this) {
      case GameId.speedTap:
        return 'Speed Tap';
      case GameId.stroopMatch:
        return 'Stroop Match';
      case GameId.patternSequence:
        return 'Number Sequence';
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
      case GameId.focusShift:
        return 'Focus Shift';
      case GameId.wordChain:
        return 'Word Chain';
      case GameId.colorDominance:
        return 'Color Dominance';
    }
  }

  IconData get icon {
    switch (this) {
      case GameId.speedTap:
        return Icons.touch_app;
      case GameId.stroopMatch:
        return Icons.psychology;
      case GameId.patternSequence:
        return Icons.functions;
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
      case GameId.focusShift:
        return Icons.psychology;
      case GameId.wordChain:
        return Icons.link;
      case GameId.colorDominance:
        return Icons.palette;
    }
  }

  String get description {
    switch (this) {
      case GameId.speedTap:
        return 'Test your reaction speed by tapping as fast as possible when the signal appears.';
      case GameId.stroopMatch:
        return 'Identify whether the color of the word matches its meaning. Overcome cognitive interference!';
      case GameId.patternSequence:
        return 'Find the pattern in number sequences and predict the next number in the series.';
      case GameId.spatialRotation:
        return 'Mentally rotate shapes and identify if they match the target orientation.';
      case GameId.memoryGrid:
        return 'Memorize the positions of highlighted squares and recreate the pattern.';
      case GameId.trailConnect:
        return 'Connect numbered dots in sequence as quickly and accurately as possible.';
      case GameId.goNoGo:
        return 'Respond to target stimuli while inhibiting responses to non-targets.';
      case GameId.colorMatch:
        return 'Watch a sequence of colors and repeat it back in the exact same order.';
      case GameId.arithmeticSprint:
        return 'Solve arithmetic problems as quickly and accurately as possible.';
      case GameId.focusShift:
        return 'Switch between identifying colors and shapes based on the task instruction.';
      case GameId.wordChain:
        return 'Create word chains by changing one letter at a time to reach the target word.';
      case GameId.colorDominance:
        return 'Find which color appears most frequently in a grid of colored squares.';
    }
  }

  List<String> get domains {
    switch (this) {
      case GameId.speedTap:
        return ['speed', 'attention'];
      case GameId.stroopMatch:
        return ['inhibition', 'attention'];
      case GameId.patternSequence:
        return ['reasoning', 'pattern recognition'];
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
      case GameId.focusShift:
        return ['attention', 'flexibility'];
      case GameId.wordChain:
        return ['verbal', 'flexibility'];
      case GameId.colorDominance:
        return ['attention', 'visual', 'frequency'];
    }
  }
}
