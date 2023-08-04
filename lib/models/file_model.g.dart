// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaFileAdapter extends TypeAdapter<MediaFile> {
  @override
  final int typeId = 0;

  @override
  MediaFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaFile(
      fields[0] as String? ?? '',  // If the value is Null, use an empty string
      fields[1] as String? ?? '',
      fields[2] as String? ?? '',
      fields[3] as String? ?? '',
      fields[4] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, MediaFile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.thumbnailPath)
      ..writeByte(3)
      ..write(obj.fileType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
