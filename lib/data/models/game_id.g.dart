// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_id.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameIdAdapter extends TypeAdapter<GameId> {
  @override
  final int typeId = 0;

  @override
  GameId read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameId.speedTap;
      case 1:
        return GameId.stroopMatch;
      case 2:
        return GameId.patternSequence;
      case 3:
        return GameId.spatialRotation;
      case 4:
        return GameId.memoryGrid;
      case 5:
        return GameId.trailConnect;
      case 6:
        return GameId.goNoGo;
      case 7:
        return GameId.colorMatch;
      case 8:
        return GameId.arithmeticSprint;
      case 9:
        return GameId.focusShift;
      case 10:
        return GameId.wordChain;
      case 11:
        return GameId.colorDominance;
      default:
        return GameId.speedTap;
    }
  }

  @override
  void write(BinaryWriter writer, GameId obj) {
    switch (obj) {
      case GameId.speedTap:
        writer.writeByte(0);
        break;
      case GameId.stroopMatch:
        writer.writeByte(1);
        break;
      case GameId.patternSequence:
        writer.writeByte(2);
        break;
      case GameId.spatialRotation:
        writer.writeByte(3);
        break;
      case GameId.memoryGrid:
        writer.writeByte(4);
        break;
      case GameId.trailConnect:
        writer.writeByte(5);
        break;
      case GameId.goNoGo:
        writer.writeByte(6);
        break;
      case GameId.colorMatch:
        writer.writeByte(7);
        break;
      case GameId.arithmeticSprint:
        writer.writeByte(8);
        break;
      case GameId.focusShift:
        writer.writeByte(9);
        break;
      case GameId.wordChain:
        writer.writeByte(10);
        break;
      case GameId.colorDominance:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
