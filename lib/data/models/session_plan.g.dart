// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionPlanAdapter extends TypeAdapter<SessionPlan> {
  @override
  final int typeId = 3;

  @override
  SessionPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionPlan(
      date: fields[0] as DateTime,
      games: (fields[1] as List).cast<GameId>(),
      seed: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SessionPlan obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.games)
      ..writeByte(2)
      ..write(obj.seed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
