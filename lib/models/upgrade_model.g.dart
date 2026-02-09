// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpgradeModelAdapter extends TypeAdapter<UpgradeModel> {
  @override
  final int typeId = 2;

  @override
  UpgradeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpgradeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      cost: fields[3] as double,
      multiplier: fields[4] as double,
      targetUnitId: fields[5] as String,
      isPurchased: fields[6] as bool,
      isUnlocked: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UpgradeModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.cost)
      ..writeByte(4)
      ..write(obj.multiplier)
      ..writeByte(5)
      ..write(obj.targetUnitId)
      ..writeByte(6)
      ..write(obj.isPurchased)
      ..writeByte(7)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpgradeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
