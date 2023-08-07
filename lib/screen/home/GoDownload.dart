import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../models/file_model.dart';

class GoDownload extends StatefulWidget {
  const GoDownload({Key? key}) : super(key: key);

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<GoDownload> {
  final int maxTextLength =12;
  final YoutubeExplode yt = YoutubeExplode();
  String videoUrl = 'https://m.youtube.com/';
  final TextEditingController _controller = TextEditingController();
  late WebViewController _webViewController; // WebView controller

  @override
  void initState() {
    super.initState();
    _controller.text = videoUrl;
  }

  Future<void> _getMetaData() async {
    if (videoUrl.contains('youtube.com/watch?v=')) {
      var video = await yt.videos.get(videoUrl);
      print('Title: ${video.title}');
      print('Author: ${video.author}');
      print('Duration: ${video.duration}');
    }
  }

  Future<String> _downloadThumbnail(String videoId) async {
    var video = await yt.videos.get(videoId);
    var title = video.title;
    title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_'); // Replace invalid characters

    var directory = await getApplicationDocumentsDirectory();
    if (title.length > maxTextLength) {
      title = title.substring(0, maxTextLength ) + '...';
    }
    var filePath = '${directory.path}/$title.jpg';

    var response = await http.get(Uri.parse(video.thumbnails.highResUrl));

    if (response.statusCode == 200) {
      await File(filePath).writeAsBytes(response.bodyBytes);
      print('Thumbnail download complete');
      print('Thumbnail file saved at: $filePath');
    } else {
      print('Failed to download thumbnail');
    }
    return filePath;
  }

  Future<void> _downloadVideo({int retryCount = 0}) async {
    try {
      var videoId = videoUrl.split('v=')[1].split('&')[0]; // Extract video ID before any '&' character
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var muxedStreamInfos = manifest.muxed.toList()
        ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
      var muxedStreamInfo = muxedStreamInfos.first;

      if (muxedStreamInfo != null) {
        var stream = yt.videos.streamsClient.get(muxedStreamInfo);

        var directory = await getApplicationDocumentsDirectory();

        var video = await yt.videos.get(videoId);
        var title = video.title;

        title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_'); // Replace invalid characters
        if (title.length > maxTextLength ) {
          title = title.substring(0, maxTextLength ) + '...';
        }
        var file = File('${directory.path}/$title.mp4');
        var duration = video.duration;


        var fileStream = file.openWrite();

        await (await stream).pipe(fileStream);

        await fileStream.flush();
        await fileStream.close();

        print('다운로드 완료');
        print('영상 저장 파일 경로 : ${file.path}');
        // Download thumbnail
        _downloadThumbnail(videoId);
        var thumbnailPath = await _downloadThumbnail(videoId);
        print('이미지 저장 완료');

        // 변수 선언
        var mediaFile = MediaFile(title, file.path, thumbnailPath, 'video',title, 'off',_formatDuration(duration!));
        Box<MediaFile>? box;

        //박스 열기
        if(Hive.isBoxOpen('mediaFiles')) {
          box = Hive.box('mediaFiles');
        } else {
          box = await Hive.openBox('mediaFiles');
        }
        // 박스 값 넣기
        box.add(mediaFile);
        print('Video metadata saved to Hive');
      }
    } catch (e) {
      print('An error occurred: $e');
      if (retryCount < 2) { // retry only if retry count is less than 3
        Future.delayed(Duration(seconds: 1), () {
          _downloadVideo(retryCount: retryCount + 1);
        });
      } else {
        print('Download failed after 3 attempts');
      }
    }
  }

  Future<void> _downloadAudio({int retryCount = 0}) async {
    try {
      var videoId = videoUrl.split('v=')[1].split('&')[0]; // Extract video ID before any '&' character
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioInfo = manifest.audioOnly.withHighestBitrate();

      if (audioInfo != null) {
        var audioStream = yt.videos.streamsClient.get(audioInfo);

        var directory = await getApplicationDocumentsDirectory();

        var video = await yt.videos.get(videoId);
        var title = video.title;
        title = title.replaceAll(RegExp(r'[\/:*?"<>|\-]'), '_'); // Replace invalid characters
        if (title.length > maxTextLength ) {
          title = title.substring(0, maxTextLength ) + '...';
        }
        var audioFile = File('${directory.path}/$title.mp3');
        var duration = video.duration;

        var audioFileStream = audioFile.openWrite();

        await (await audioStream).pipe(audioFileStream);

        await audioFileStream.flush();
        await audioFileStream.close();

        print('Download complete');
        print('Audio file saved at: ${audioFile.path}');

        // Download thumbnail
        _downloadThumbnail(videoId);
        var thumbnailPath = await _downloadThumbnail(videoId);

        //변수 선언
        var mediaFile = MediaFile(title, audioFile.path, thumbnailPath, 'audio',title,'off',_formatDuration(duration!));
        Box<MediaFile>? box;

        //박스 열기
        if(Hive.isBoxOpen('mediaFiles')) {
          box = Hive.box('mediaFiles');
        } else {
          box = await Hive.openBox('mediaFiles');
        }
        //박스 넣기
        box.add(mediaFile);
        print('Audio metadata saved to Hive');

      }
    } catch (e) {
      print('An error occurred: $e');
      if (retryCount < 2) { // retry only if retry count is less than 3
        Future.delayed(Duration(seconds: 1), () {
          _downloadAudio(retryCount: retryCount + 1);
        });
      }
    }
  }

  Future<void> _showDownloadDialog() async {
    _webViewController.reload(); // Reload the WebView before showing the dialog
    switch (await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.all(16.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select download format',
                style: TextStyle(color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.cancel, color: Colors.black54),
              ),
            ],
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Video');
              },
              child: const Text(
                'Video',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Audio');
              },
              child: const Text(
                'Audio',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        );
      },
    )) {
      case 'Video':
        _downloadVideo();
        break;
      case 'Audio':
        _downloadAudio();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: DialogTheme(
          titleTextStyle: TextStyle(color: Colors.blue),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter a search term',
            ),
            onSubmitted: (url) {
              if (!url.startsWith('http')) {
                url = 'https://$url';
              }
              _webViewController.loadUrl(url);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.download),
              onPressed: _showDownloadDialog,
            ),
          ],
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: videoUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onPageStarted: (url) {
                setState(() {
                  _controller.text = url;
                  if (url.contains('youtube.com/watch?v=')) {
                    videoUrl = url;
                    _getMetaData();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    yt.close();
    super.dispose();
  }
}