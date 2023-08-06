import 'dart:ffi';

import 'package:hive/hive.dart';
part 'file_model.g.dart';  // Add this line
@HiveType(typeId: 0)
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


  MediaFile(this.title, this.filePath, this.thumbnailPath, this.fileType, this.description, this.like );

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
    var audioFiles = box.values.where((mediaFile) => mediaFile.fileType == 'audio').toList();
    audioFiles.forEach((file) {
      print('Loaded file: ${file.title} with like status: ${file.like}');
    });
    return audioFiles;
  }

  static Future<List<MediaFile>> loadAllVideoFiles() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    return box.values.where((mediaFile) => mediaFile.fileType == 'video').toList();
  }
  static Future<List<MediaFile>> loadAllLikedAudioFiles() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    return box.values.where((mediaFile) => (mediaFile.fileType == 'video' && mediaFile.like == true)).toList();
  }

}
