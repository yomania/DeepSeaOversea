// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResourceModelAdapter extends TypeAdapter<ResourceModel> {
  @override
  final int typeId = 0;

  @override
  ResourceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResourceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ResourceModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
