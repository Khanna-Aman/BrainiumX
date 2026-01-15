// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameConfigAdapter extends TypeAdapter<GameConfig> {
  @override
  final int typeId = 2;

  @override
  GameConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameConfig(
      gameId: fields[0] as GameId,
      unlocked: fields[1] as bool,
      difficultyRating: fields[2] as double,
      highScore: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GameConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.gameId)
      ..writeByte(1)
      ..write(obj.unlocked)
      ..writeByte(2)
      ..write(obj.difficultyRating)
      ..writeByte(3)
      ..write(obj.highScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
