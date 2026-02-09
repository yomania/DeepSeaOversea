// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitModelAdapter extends TypeAdapter<UnitModel> {
  @override
  final int typeId = 1;

  @override
  UnitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      baseCost: fields[3] as double,
      baseProduction: fields[4] as double,
      costGrowthRate: fields[5] as double,
      count: fields[6] as int,
      isUnlocked: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UnitModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.baseCost)
      ..writeByte(4)
      ..write(obj.baseProduction)
      ..writeByte(5)
      ..write(obj.costGrowthRate)
      ..writeByte(6)
      ..write(obj.count)
      ..writeByte(7)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
