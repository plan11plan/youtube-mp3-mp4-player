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
  final int maxTextLength = 12;
  final YoutubeExplode yt = YoutubeExplode();
  String videoUrl = 'https://m.youtube.com/';
  final TextEditingController _controller = TextEditingController();
  late WebViewController _webViewController;

  void _showDialog(String title, String content, List<Widget> actions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Colors.black)),
          content: Text(content, style: TextStyle(color: Colors.black)),
          actions: actions,
        );
      },
    );
  }

  void _showDownloadCompleteDialog() {
    _showDialog(
      "Alarm",
      "download complete!",
      [
        TextButton(
          child: Text("ok", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )
      ],
    );
  }



  void _showDownloadFailedDialog() {
    _showDialog(
      "Fail to download",
        "1. Please choose just 1 video             2. Even though you selected 1 video, If the http condition is not good , please retry.",
      [
        TextButton(
          child: Text("retry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.of(context).pop();
            _download('Video');
          },
          style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        TextButton(
          child: Text("cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )
      ],
    );
  }


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
    var title = _formatTitle(video.title);
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

  Future<void> _download(String type, {int retryCount = 0}) async {
    if(retryCount == 0)_showLoadingDialog();
    try {
      var videoId = _extractVideoId(videoUrl);
      var directory = await getApplicationDocumentsDirectory();
      var video = await yt.videos.get(videoId);
      var title = _formatTitle(video.title);

      if (type == 'Video') {
        await _downloadVideoContent(videoId, directory, title, video.duration);
      } else {
        await _downloadAudioContent(videoId, directory, title, video.duration);
      }

      Navigator.of(context).pop();
      _showDownloadCompleteDialog();
    } catch (e) {
      if (retryCount < 2) {
        Future.delayed(Duration(seconds: 1), () {
          _download(type, retryCount: retryCount + 1);
        });
      } else {
        Navigator.of(context).pop();
        _showDownloadFailedDialog();
      }
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

      // Download thumbnail
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

      var thumbnailPath = await _downloadThumbnail(videoId);
      var mediaFile = MediaFile(title, audioFile.path, thumbnailPath, 'audio', title, 'off', _formatDuration(duration!));
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

  String _extractVideoId(String url) {
    return videoUrl.split('v=')[1].split('&')[0];
  }

  String _formatTitle(String title) {
    title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
    return title.length > maxTextLength ? title.substring(0, maxTextLength) + '...' : title;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              SizedBox(width: 20),
              Expanded(  // 여기에 Expanded 위젯을 추가합니다.
                child: Text(
                  "downloading..",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();  // 다이얼로그를 닫습니다.
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "cancel",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titlePadding: EdgeInsets.all(16.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(  // Expanded 위젯을 추가하여 Text 위젯이 사용 가능한 공간 내에서만 확장되도록 합니다.
                child: Text(
                  'Select format',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.cancel, color: Colors.black54),
              ),
            ],
          ),

            children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'Video'),
                      child: Text(
                        'Video',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, 'Audio'),
                    child: Text(
                      'Audio',
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )



            ),
          ],
        );
      },
    )) {
      case 'Video':
        _download('Video');
        break;
      case 'Audio':
        _download('Audio');
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
          backgroundColor: Colors.black,
          title: TextField(
            controller: _controller,
            style: TextStyle(color: Colors.white), // 텍스트 컬러 변경
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), // 둥근 모서리 추가
                borderSide: BorderSide.none, // 테두리 제거
              ),
              hintText: 'Enter a search term',
              hintStyle: TextStyle(color: Colors.white70), // 힌트 텍스트 컬러 변경
              prefixIcon: Icon(Icons.search, color: Colors.white70), // 검색 아이콘 추가
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
              icon: Icon(Icons.help, color: Colors.white),  // <-- 도움말 아이콘을 추가합니다.
              onPressed: () {
                // 도움말 아이콘을 누르면 표시될 대화상자입니다.
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // 둥근 모서리 추가
                      ),
                      title: Text("manual", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      content: Text(
                        "1.you can only download in just one video page -> select video. \n "
                            "2.there is some YouTube connectivity issue.\n but i sure if you get some retry, you can download.",
                        style: TextStyle(color: Colors.black54), // 텍스트 색상을 약간 연하게 조정
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text("cancel", style: TextStyle(color: Colors.black)),
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    );

                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.download, color: Colors.white),
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
