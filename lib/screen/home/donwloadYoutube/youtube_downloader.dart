import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/file_model.dart';

class YoutubeDownloader {
  final YoutubeExplode yt = YoutubeExplode();

  Future<void> getMetaData(String videoUrl) async {
    if (videoUrl.contains('youtube.com/watch?v=')) {
      var video = await yt.videos.get(videoUrl);
      print('Title: ${video.title}');
      print('Author: ${video.author}');
      print('Duration: ${video.duration}');
    }
  }

  Future<String> downloadThumbnail(String videoId) async {
    var video = await yt.videos.get(videoId);
    var title = formatTitle(video.title);
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$title.jpg';
    var response = await http.get(Uri.parse(video.thumbnails.highResUrl));
    print(filePath);
    if (response.statusCode == 200) {
      await File(filePath).writeAsBytes(response.bodyBytes);
      print('Thumbnail download complete');
      print('Thumbnail file saved at: $filePath');
    } else {
      print('Failed to download thumbnail');
    }
    return filePath;
  }

  Future<void> download(String videoId, String type, Directory directory) async {
    var video = await yt.videos.get(videoId);
    var title = formatTitle(video.title);

    if (type == 'Video') {
      await _downloadVideoContent(videoId, directory, title, video.duration);
    } else {
      await _downloadAudioContent(videoId, directory, title, video.duration);
    }
  }

  Future<void> _downloadVideoContent(String videoId, Directory directory, String title, Duration? duration) async {
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var muxedStreamInfos = manifest.muxed.toList()
      ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
    var muxedStreamInfo = muxedStreamInfos.first;

    if (muxedStreamInfo != null) {
      var stream = yt.videos.streamsClient.get(muxedStreamInfo);
      var file = File('${directory.path}/$title.mp4');
      var fileStream = file.openWrite();

      await (await stream).pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();

      print('다운로드 완료');
      print('영상 저장 파일 경로 : ${file.path}');

      var thumbnailPath = await downloadThumbnail(videoId);

      var mediaFile = MediaFile(title, file.path, thumbnailPath, 'video', title, 'off', formatDuration(duration!));
      Box<MediaFile>? box;

      if (Hive.isBoxOpen('mediaFiles')) {
        box = Hive.box('mediaFiles');
      } else {
        box = await Hive.openBox('mediaFiles');
      }
      box.add(mediaFile);
      print('Video metadata saved to Hive');
    }
  }

  Future<void> _downloadAudioContent(String videoId, Directory directory, String title, Duration? duration) async {
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var audioInfo = manifest.audio.withHighestBitrate();

    if (audioInfo != null) {
      var audioStream = yt.videos.streamsClient.get(audioInfo);
      var audioFile = File('${directory.path}/$title.mp3');
      var audioFileStream = audioFile.openWrite();

      await (await audioStream).pipe(audioFileStream);
      await audioFileStream.flush();
      await audioFileStream.close();

      print('Download complete');
      print('Audio file saved at: ${audioFile.path}');

      var thumbnailPath = await downloadThumbnail(videoId);
      var mediaFile = MediaFile(title, audioFile.path, thumbnailPath, 'audio', title, 'off', formatDuration(duration!));
      Box<MediaFile>? box;

      if (Hive.isBoxOpen('mediaFiles')) {
        box = Hive.box('mediaFiles');
      } else {
        box = await Hive.openBox('mediaFiles');
      }
      box.add(mediaFile);
      print('Audio metadata saved to Hive');
    }
  }

  String extractVideoId(String url) {
    return url.split('v=')[1].split('&')[0];
  }

  String formatTitle(String title) {
    const int maxTextLength = 12;
    title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
    return title.length > maxTextLength ? title.substring(0, maxTextLength) + '...' : title;
  }

  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }

  void close() {
    yt.close();
  }
}
