import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Youtube extends StatefulWidget {
  const Youtube({Key? key}) : super(key: key);

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  final TextEditingController _urlController = TextEditingController(text: 'https://www.youtube.com/');
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _urlController,
          onSubmitted: (url) {
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
          autocorrect: false, // 자동 수정 기능 비활성화
        ),
//
      ),
      body: WebView(
        initialUrl: 'https://www.youtube.com/',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }
}
