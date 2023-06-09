// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CoinsModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoinsModelAdapter extends TypeAdapter<CoinsModel> {
  @override
  final int typeId = 2;

  @override
  CoinsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinsModel(
      id: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CoinsModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
