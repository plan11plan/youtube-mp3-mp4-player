import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
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
  final int maxTextLength =12; // Title 허용 최대 길이.
  final YoutubeExplode yt = YoutubeExplode();
  String videoUrl = 'https://m.youtube.com/'; // 나중에 다운로드 버튼 누르면, 해당 영상으로 초기화
  final TextEditingController _controller = TextEditingController();
  late WebViewController _webViewController; // 새로고침하려고 가져옴.

  @override
  void initState() {
    super.initState();
    _controller.text = videoUrl;
  }
  // Future<void> _getMetaData() async {
  //   if (videoUrl.contains('youtube.com/watch?v=')) {
  //     var video = await yt.videos.get(videoUrl);
  //     print('Title: ${video.title}');
  //     print('Author: ${video.author}');
  //     print('Duration: ${video.duration}');
  //   }
  // }
  String _formatDuration(Duration duration) {
    print("@@@@@@@@@@@@@@@@@@@@@@@@@ duration 조작 시작 및 종료 @@@@@@@@@@@@@@@@@@@@@@@@@");

    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }

  Future<String> _downloadThumbnail(String videoId) async {
    // 썸네일 다운로드
    print("@@@@@@@@@@@@@@@@@@@@@@@@@ 썸네일 다운로드 메서드() 호출 @@@@@@@@@@@@@@@@@@@@@@@@@");
    var video = await yt.videos.get(videoId);

    //제목 필터링
    var title = video.title;
    title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_'); // Replace invalid characters
    if (title.length > maxTextLength) {
      title = title.substring(0, maxTextLength ) + '...';
    }
    //저장할 파일 경로.
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$title.jpg';

    //
    print("@@@@@@@@@@@@@@@@@@@@@@@@@ 썸네일 다운로드 시작  @@@@@@@@@@@@@@@@@@@@@@@@@");
    var response = await http.get(Uri.parse(video.thumbnails.highResUrl));
    print("@@@@@@@@@@@@@@@@@@@@@@@@@ 썸네일 다운로드 완료  @@@@@@@@@@@@@@@@@@@@@@@@@");

    if (response.statusCode == 200) {
      print("@@@@@@@@@@@@@@@@@@@@@@@@@ 썸네일 파일에 넣어주기 시작  @@@@@@@@@@@@@@@@@@@@@@@@@");
      await File(filePath).writeAsBytes(response.bodyBytes);
      print("@@@@@@@@@@@@@@@@@@@@@@@@@ 썸네일 파일에 넣어주기 완료  @@@@@@@@@@@@@@@@@@@@@@@@@");

      print('Thumbnail file saved at: $filePath');
    } else {
      print('Failed to download thumbnail');
    }
    print("@@@@@@@@@@@@@@@@@@@@@@@@@ 썸네일 다운로드 메서드() 호출 @@@@@@@@@@@@@@@@@@@@@@@@@");

    return filePath;
  }

  Future<void> _downloadAudio({int retryCount = 0}) async {
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  #1 오디오 다운로드() 메서드 호출  @@@@@@@@@@@@@@@@@@@@@@@@@");

    try {
      var videoId = videoUrl.split('v=')[1].split('&')[0];
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      // var audioInfo = manifest.audioOnly.withHighestBitrate();
      var audioInfo = manifest.audio.withHighestBitrate();


      if (audioInfo != null) {
        var audioStream = yt.videos.streamsClient.get(audioInfo);

        //파일 열고,
        var directory = await getApplicationDocumentsDirectory();
        var video = await yt.videos.get(videoId);
        var title = video.title;
        title = title.replaceAll(RegExp(r'[\/:*?"<>|\-]'), '_');
        if (title.length > maxTextLength) {
          title = title.substring(0, maxTextLength) + '...';
        }
        var audioFile = File('${directory.path}/$title.mp3');
        var duration = video.duration;

        var audioFileStream = audioFile.openWrite();

        await (await audioStream).pipe(audioFileStream);

        await audioFileStream.flush();
        await audioFileStream.close();

        print('Download complete');
        print('Audio file saved at: ${audioFile.path}');

        // Reduce Audio Quality using FFmpeg
        var compressedAudioFile = File('${directory.path}/$title.mp3');
        await FFmpegKit.execute('-i ${audioFile.path} -b:a 64k ${compressedAudioFile.path}').then((session) async {
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            print("Audio compression successful using FFmpeg");
          } else {
            print("Audio compression error using FFmpeg");
          }
        });

        // Download thumbnail
        var thumbnailPath = await _downloadThumbnail(videoId);

        // Save to Hive
        var mediaFile = MediaFile(title, compressedAudioFile.path, thumbnailPath, 'audio', title, 'off', _formatDuration(duration!));
        Box<MediaFile>? box;
        if (Hive.isBoxOpen('mediaFiles')) {
          box = Hive.box('mediaFiles');
        } else {
          box = await Hive.openBox('mediaFiles');
        }
        box.add(mediaFile);
        print('Audio metadata saved to Hive');
      }
    } catch (e) {
      print(' ###### Failed Download ...######.');
      if (retryCount < 2) {
        Future.delayed(Duration(seconds: 1), () {
          _downloadAudio(retryCount: retryCount + 1);
        });
      }
    }
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  #1 오디오 다운로드() 메서드 종료  @@@@@@@@@@@@@@@@@@@@@@@@@");

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


  Future<void> reduceAudioQualityWithFFmpeg(String inputPath, String outputPath) async {
    await FFmpegKit.execute('-i $inputPath -b:a 64k $outputPath').then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print("Audio compression successful using FFmpeg");
      } else if (ReturnCode.isCancel(returnCode)) {
        print("Audio compression cancelled");
      } else {
        print("Audio compression error using FFmpeg");
      }
    });
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
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }



  @override
  void dispose() {
    yt.close();
    super.dispose();
  }
}