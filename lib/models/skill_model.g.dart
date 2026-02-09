// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillModelAdapter extends TypeAdapter<SkillModel> {
  @override
  final int typeId = 3;

  @override
  SkillModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      resourceCost: (fields[3] as Map).cast<String, double>(),
      requiredLevel: fields[4] as int,
      requiredSkillIds: (fields[5] as List).cast<String>(),
      effects: (fields[6] as Map).cast<String, dynamic>(),
      x: fields[7] as double,
      y: fields[8] as double,
      isPurchased: fields[9] as bool,
      isUnlocked: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SkillModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.resourceCost)
      ..writeByte(4)
      ..write(obj.requiredLevel)
      ..writeByte(5)
      ..write(obj.requiredSkillIds)
      ..writeByte(6)
      ..write(obj.effects)
      ..writeByte(7)
      ..write(obj.x)
      ..writeByte(8)
      ..write(obj.y)
      ..writeByte(9)
      ..write(obj.isPurchased)
      ..writeByte(10)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
