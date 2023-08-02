import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';

class GoDownload extends StatefulWidget {
  const GoDownload({Key? key}) : super(key: key);

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<GoDownload> {
  final YoutubeExplode yt = YoutubeExplode();
  final String videoUrl = 'https://www.youtube.com/watch?v=Pp07icnTPGE'; // The URL of the video you chose.

  @override
  void initState() {
    super.initState();
    _getMetaData();
  }//

  Future<void> _getMetaData() async {
    var video = await yt.videos.get(videoUrl);
    print('Title: ${video.title}');
    print('Author: ${video.author}');
    print('Duration: ${video.duration}');
  }

  Future<void> _downloadVideo() async {
    var manifest = await yt.videos.streamsClient.getManifest(videoUrl.split('v=')[1]);

    var muxedStreamInfos = manifest.muxed.toList()
      ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
    var muxedStreamInfo = muxedStreamInfos.first;

    if (muxedStreamInfo != null) {
      var stream = yt.videos.streamsClient.get(muxedStreamInfo);

      var directory = await getApplicationDocumentsDirectory();
      var file = File('${directory.path}/video.mp4');

      var fileStream = file.openWrite();

      await (await stream).pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();

      print('Download complete');
      print('Video file saved at: ${file.path}');
    }
  }

  Future<void> _downloadAudio() async {
    var manifest = await yt.videos.streamsClient.getManifest(videoUrl.split('v=')[1]);
    var audioInfo = manifest.audioOnly.withHighestBitrate();

    if (audioInfo != null) {
      var audioStream = yt.videos.streamsClient.get(audioInfo);

      var directory = await getApplicationDocumentsDirectory();
      var audioFile = File('${directory.path}/audio.mp3');

      var audioFileStream = audioFile.openWrite();

      await (await audioStream).pipe(audioFileStream);

      await audioFileStream.flush();
      await audioFileStream.close();

      print('Download complete');
      print('Audio file saved at: ${audioFile.path}');
    }
  }

  Future<void> _showDownloadDialog() async {
    switch (await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select download format',
              style: TextStyle(color: Colors.black54)),
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
          title: Text('YouTube Downloader'),
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
