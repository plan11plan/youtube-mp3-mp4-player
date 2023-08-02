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

  Future<void> _downloadVideo() async {
    try {
      var videoId = videoUrl.split('v=')[1].split('&')[0]; // Extract video ID before any '&' character
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var muxedStreamInfos = manifest.muxed.toList()
        ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
      var muxedStreamInfo = muxedStreamInfos.first;

      if (muxedStreamInfo != null) {
        var stream = yt.videos.streamsClient.get(muxedStreamInfo);

        var directory = await getApplicationDocumentsDirectory();

        var video = await yt.videos.get(videoUrl);
        var title = video.title;
        title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_'); // Replace invalid characters

        var file = File('${directory.path}/$title.mp4');

        var fileStream = file.openWrite();

        await (await stream).pipe(fileStream);

        await fileStream.flush();
        await fileStream.close();

        print('Download complete');
        print('Video file saved at: ${file.path}');
      }
    } catch (e) {
      print('An error occurred: $e');
      _downloadVideo(); // Retry download on failure
    }
  }

  Future<void> _downloadAudio() async {
    try {
      var videoId = videoUrl.split('v=')[1].split('&')[0]; // Extract video ID before any '&' character
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioInfo = manifest.audioOnly.withHighestBitrate();

      if (audioInfo != null) {
        var audioStream = yt.videos.streamsClient.get(audioInfo);

        var directory = await getApplicationDocumentsDirectory();

        var video = await yt.videos.get(videoUrl);
        var title = video.title;
        title = title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_'); // Replace invalid characters

        var audioFile = File('${directory.path}/$title.mp3');

        var audioFileStream = audioFile.openWrite();

        await (await audioStream).pipe(audioFileStream);

        await audioFileStream.flush();
        await audioFileStream.close();

        print('Download complete');
        print('Audio file saved at: ${audioFile.path}');
      }
    } catch (e) {
      print('An error occurred: $e');
      _downloadAudio(); // Retry download on failure
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

  @override
  void dispose() {
    yt.close();
    super.dispose();
  }
}
