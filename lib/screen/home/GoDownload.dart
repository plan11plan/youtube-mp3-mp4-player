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
  final int maxTextLength = 12;
  final YoutubeExplode yt = YoutubeExplode();
  String videoUrl = 'https://m.youtube.com/';
  final TextEditingController _controller = TextEditingController();
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _controller.text = videoUrl;
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }

  Future<String> _downloadThumbnail(String videoId) async {
    var video = await yt.videos.get(videoId);
    var title = video.title;
    title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
    if (title.length > maxTextLength) {
      title = title.substring(0, maxTextLength) + '...';
    }
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$title.jpg';
    var response = await http.get(Uri.parse(video.thumbnails.highResUrl));
    if (response.statusCode == 200) {
      await File(filePath).writeAsBytes(response.bodyBytes);
    } else {
      print('Failed to download thumbnail');
    }
    return filePath;
  }

  Future<void> _downloadAudio({int retryCount = 0}) async {
    try {
      var videoId = videoUrl.split('v=')[1].split('&')[0];
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioInfo = manifest.audio.withHighestBitrate();
      if (audioInfo != null) {
        var audioStream = yt.videos.streamsClient.get(audioInfo);
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
        var compressedAudioFile = File('${directory.path}/$title.mp3');
        await FFmpegKit.execute('-i ${audioFile.path} -b:a 64k ${compressedAudioFile.path}').then((session) async {
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            print("Audio compression successful using FFmpeg");
          } else {
            print("Audio compression error using FFmpeg");
          }
        });
        var thumbnailPath = await _downloadThumbnail(videoId);
        var mediaFile = MediaFile(title, compressedAudioFile.path, thumbnailPath, 'audio', title, 'off', _formatDuration(duration!));
        Box<MediaFile>? box;
        if (Hive.isBoxOpen('mediaFiles')) {
          box = Hive.box('mediaFiles');
        } else {
          box = await Hive.openBox('mediaFiles');
        }
        box.add(mediaFile);
        print('Audio metadata saved to Hive');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("다운로드 완료!",style: TextStyle(color: Colors.black),),
            actions: <Widget>[
              TextButton(
                child: Text('확인',style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('다운로드 실패');
      if (retryCount < 2) {
        String? action = await showDownloadProgressDialog(context, initialMessage: '다운로드 실패. 재시도하시겠습니까?',);
        if (action == 'retry') {
          _downloadAudio(retryCount: retryCount + 1);
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("3번의 시도 끝에 다운로드 실패",style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                child: Text('확인',style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _downloadVideo({int retryCount = 0}) async {
    try {
      var videoId = videoUrl.split('v=')[1].split('&')[0];
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var muxedStreamInfos = manifest.muxed.toList()
        ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
      var muxedStreamInfo = muxedStreamInfos.first;
      if (muxedStreamInfo != null) {
        var stream = yt.videos.streamsClient.get(muxedStreamInfo);
        var directory = await getApplicationDocumentsDirectory();
        var video = await yt.videos.get(videoId);
        var title = video.title;
        title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
        if (title.length > maxTextLength) {
          title = title.substring(0, maxTextLength) + '...';
        }
        var file = File('${directory.path}/$title.mp4');
        var duration = video.duration;
        var fileStream = file.openWrite();
        await (await stream).pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();
        var thumbnailPath = await _downloadThumbnail(videoId);
        var mediaFile = MediaFile(title, file.path, thumbnailPath, 'video', title, 'off', _formatDuration(duration!));
        Box<MediaFile>? box;
        if (Hive.isBoxOpen('mediaFiles')) {
          box = Hive.box('mediaFiles');
        } else {
          box = await Hive.openBox('mediaFiles');
        }
        box.add(mediaFile);
        print('Video metadata saved to Hive');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("다운로드 완료!",style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                child: Text('확인',style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('다운로드 실패');
      if (retryCount < 2) {
        String? action = await showDownloadProgressDialog(context, initialMessage: '다운로드 실패. 재시도하시겠습니까?');
        if (action == 'retry') {
          _downloadVideo(retryCount: retryCount + 1);
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("3번의 시도 끝에 다운로드 실패",style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                child: Text('확인',style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Future<String?> showDownloadProgressDialog(BuildContext context, {required String initialMessage}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Text(initialMessage),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('재시도',style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop('retry');
                      },
                    ),
                    TextButton(
                      child: Text('취소',style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop('cancel');
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDownloadDialog() async {
    _webViewController.reload();
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
        showDownloadProgressDialog(context, initialMessage: '다운로딩 중...',);
        _downloadVideo();
        break;
      case 'Audio':
        showDownloadProgressDialog(context, initialMessage: '다운로딩 중...');
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
