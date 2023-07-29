import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Youtube extends StatefulWidget {
  const Youtube({Key? key}) : super(key: key);

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: 'https://www.youtube.com/',
        javascriptMode: JavascriptMode.unrestricted,
    )
    );
  }
}
