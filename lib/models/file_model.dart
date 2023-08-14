import 'dart:ffi';

import 'package:hive_flutter/hive_flutter.dart';

part 'file_model.g.dart';  // Add this li ne
@HiveType(typeId: 0) // 다른 클래스 만들때, type Id 증가하게 만들면됨.
class MediaFile {
  @HiveField(0)
  String title;

  @HiveField(1)
  String filePath;

  @HiveField(2)
  String thumbnailPath;

  @HiveField(3)
  String fileType; // "video" or "audio"

  @HiveField(4)
  String description;

  @HiveField(5)
  String like;

  @HiveField(6)
  String duration;



  MediaFile(this.title, this.filePath, this.thumbnailPath, this.fileType, this.description, this.like, this.duration);

  void updateTitleAndDescription(String newTitle, String newDescription) {
    this.title = newTitle;
    this.description = newDescription;
    Hive.box<MediaFile>('mediaFiles').put(this.filePath, this);
  }

  void updateLikeStatus(String newLikeStatus) {
    this.like = newLikeStatus;
    Hive.box<MediaFile>('mediaFiles').put(this.filePath, this);
  }

  static Future<List<MediaFile>> loadAllAudioFiles() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    return box.values.where((mediaFile) => mediaFile.fileType == 'audio').toList();
  }

  static Future<List<MediaFile>> loadAllVideoFiles() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    return box.values.where((mediaFile) => mediaFile.fileType == 'video').toList();
  }
  static Future<List<String>> loadAllAudioFileTitles() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    var audioFiles = box.values.where((mediaFile) => mediaFile.fileType == 'audio').toList();

    return audioFiles.map((mediaFile) => mediaFile.title).toList();
  }

}

@HiveType(typeId: 1)  // 기존 MediaFile의 typeId가 0이므로, 1로 설정합니다.
class Playlist {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> mediaFileTitles; // 여기에는 MediaFile의 title들을 저장합니다.

  Playlist({required this.name, required this.mediaFileTitles});

  Playlist copyWith({String? name, List<String>? mediaFileTitles}) {
    return Playlist(
      name: name ?? this.name,
      mediaFileTitles: mediaFileTitles ?? this.mediaFileTitles,
    );
  }
}
