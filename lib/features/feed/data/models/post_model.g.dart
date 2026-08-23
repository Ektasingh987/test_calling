// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostUserModelAdapter extends TypeAdapter<PostUserModel> {
  @override
  final int typeId = 1;

  @override
  PostUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostUserModel(
      id: fields[0] as int,
      username: fields[1] as String,
      profilePicture: fields[2] as String?,
      fullName: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PostUserModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.profilePicture)
      ..writeByte(3)
      ..write(obj.fullName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostModelAdapter extends TypeAdapter<PostModel> {
  @override
  final int typeId = 0;

  @override
  PostModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostModel(
      id: fields[0] as int,
      user: fields[1] as PostUserModel,
      caption: fields[2] as String?,
      image: fields[3] as String?,
      video: fields[4] as String?,
      likesCount: fields[5] as int,
      commentsCount: fields[6] as int,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PostModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.caption)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.video)
      ..writeByte(5)
      ..write(obj.likesCount)
      ..writeByte(6)
      ..write(obj.commentsCount)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

