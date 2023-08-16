import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'youtube_downloader.dart';  // 새로 만든 파일을 import 합니다.

class GoDownload extends StatefulWidget {
  const GoDownload({Key? key}) : super(key: key);
  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<GoDownload> {
  final YoutubeDownloader _downloader = YoutubeDownloader();
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
    await _downloader.getMetaData(videoUrl);
  }

  Future<void> _download(String type, {int retryCount = 0}) async {
    if(retryCount == 0)_showLoadingDialog();
    try {
      var videoId = _downloader.extractVideoId(videoUrl);
      var directory = await getApplicationDocumentsDirectory();

      await _downloader.download(videoId, type, directory);

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
              Expanded(
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
              Expanded(
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
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter a search term',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.search, color: Colors.white70),
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
              icon: Icon(Icons.help, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Text("manual", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      content: Text(
                        "1.you can only download in just one video page -> select video. \n "
                            "2.there is some YouTube connectivity issue.\n but i sure if you get some retry, you can download.",
                        style: TextStyle(color: Colors.black54),
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

  @override
  void dispose() {
    _downloader.close();
    super.dispose();
  }
}
