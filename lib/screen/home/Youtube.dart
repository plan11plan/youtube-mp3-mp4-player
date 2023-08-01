import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_downloader/youtube_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Youtube extends StatefulWidget {
  const Youtube({Key? key}) : super(key: key);

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  final TextEditingController _urlController = TextEditingController(text: 'https://www.youtube.com/watch?v=_E825s0CGM0');
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _urlController,
          onSubmitted: (url) {
            url = url.trim();
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              url = 'http://' + url;
            }
            _webViewController.loadUrl(url);
          },
          decoration: InputDecoration(
            hintText: 'Enter URL here...',
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          autocorrect: false,
        ),
      ),
      body: WebView(
        initialUrl: 'https://www.youtube.com/watch?v=_E825s0CGM0',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onPageFinished: (url) {
          _urlController.text = url;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String url = _urlController.text;
          if (YoutubeDownloader().isValidYoutubeUrl(url)) {
            VideoInfo? videoInfo = await YoutubeDownloader().downloadYoutubeVideo(url, 'mp4');
            if (videoInfo != null) {
              // 다운로드 URL에서 파일 다운로드
              var response = await http.get(Uri.parse(videoInfo.downloadUrl!));

              // 앱의 임시 디렉토리에 파일 저장
              var tempDir = await getTemporaryDirectory();
              var file = File('${tempDir.path}/video.mp4');
              await file.writeAsBytes(response.bodyBytes);

              // 파일이 존재하는지 확인
              if (await file.exists()) {
                print('File downloaded to ${file.path}');
              } else {
                print('File download failed');
              }

              // 썸네일 다운로드
              var thumbResponse = await http.get(Uri.parse(videoInfo.thumbnailUrl!));
              var thumbFile = File('${tempDir.path}/thumbnail.jpg');
              await thumbFile.writeAsBytes(thumbResponse.bodyBytes);

              // 썸네일 파일이 존재하는지 확인
              if (await thumbFile.exists()) {
                print('Thumbnail downloaded to ${thumbFile.path}');
              } else {
                print('Thumbnail download failed');
              }
            }
          }
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
