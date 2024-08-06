// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WalletModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletModelAdapter extends TypeAdapter<WalletModel> {
  @override
  final int typeId = 3;

  @override
  WalletModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletModel(
      id: fields[0] as String,
      name: fields[1] as String,
      walletType: fields[2] as String?,
      blockchains: fields[3] as String?,
      link: fields[4] as String?,
      droid: fields[5] as String?,
      ios: fields[6] as String?,
      sort: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WalletModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.walletType)
      ..writeByte(3)
      ..write(obj.blockchains)
      ..writeByte(4)
      ..write(obj.link)
      ..writeByte(5)
      ..write(obj.droid)
      ..writeByte(6)
      ..write(obj.ios)
      ..writeByte(7)
      ..write(obj.sort);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
