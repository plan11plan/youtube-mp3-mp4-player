import 'package:hive/hive.dart';
part 'file_model.g.dart';  // Add this line

@HiveType(typeId: 0)
class MediaFile {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final String thumbnailPath;

  @HiveField(3)
  final String fileType; // "video" or "audio"

  @HiveField(4)
  final String description;


  MediaFile(this.title, this.filePath, this.thumbnailPath, this.fileType, this.description);

  // This static method loads all audio files from Hive.
  static Future<List<MediaFile>> loadAllAudioFiles() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    return box.values.where((mediaFile) => mediaFile.fileType == 'audio').toList();
  }

  // This static method loads all audio files from Hive.
  static Future<List<MediaFile>> loadAllVideoFiles() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    return box.values.where((mediaFile) => mediaFile.fileType == 'video').toList();
  }


}
