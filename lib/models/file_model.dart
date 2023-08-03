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

  MediaFile(this.title, this.filePath, this.thumbnailPath, this.fileType);
}
