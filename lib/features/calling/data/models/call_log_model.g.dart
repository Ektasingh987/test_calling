// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallLogModelAdapter extends TypeAdapter<CallLogModel> {
  @override
  final int typeId = 2;

  @override
  CallLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallLogModel(
      id: fields[0] as String,
      callerName: fields[1] as String,
      callerAvatar: fields[2] as String?,
      callType: fields[3] as int,
      callStatus: fields[4] as int,
      durationSeconds: fields[5] as int,
      dateTime: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CallLogModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.callerName)
      ..writeByte(2)
      ..write(obj.callerAvatar)
      ..writeByte(3)
      ..write(obj.callType)
      ..writeByte(4)
      ..write(obj.callStatus)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

