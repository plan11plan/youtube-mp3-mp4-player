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
        fields[0] as String? ?? "",
        fields[1] as String? ?? "",
        fields[2] as String? ?? "",
        fields[3] as String? ?? "",
        fields[4] as String? ?? "",
        fields[5] as String? ?? "",
        fields[6] as String? ?? ""

    );
  }

  @override
  void write(BinaryWriter writer, MediaFile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.thumbnailPath)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.like)
      ..writeByte(6)
      ..write(obj.duration);
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
class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 1; // 이미 file_model.dart에서 typeId가 1로 설정되어 있습니다.

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      name: fields[0] as String? ?? "",
      mediaFileTitles: (fields[1] as List? ?? []).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(2) // 두 개의 필드가 있습니다.
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.mediaFileTitles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PlaylistAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
