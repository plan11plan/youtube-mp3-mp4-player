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
  String videoUrl = 'https://www.google.com'; // Start with Google Chrome.
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

  Future<void> _downloadVideo() async {
    if (videoUrl.contains('youtube.com/watch?v=')) {
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
  }

  Future<void> _downloadAudio() async {
    if (videoUrl.contains('youtube.com/watch?v=')) {
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
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _webViewController.reload(); // Reload WebView
              },
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
                  print('Current URL: $url'); // Print the current URL.
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
