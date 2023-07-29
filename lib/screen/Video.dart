import 'package:flutter/material.dart';

class Video extends StatefulWidget {

  @override
  State<Video> createState() => _UploadState();
}

class _UploadState extends State<Video> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("This is Video Page.Video.dart"),
    );
  }
}