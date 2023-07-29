import 'package:flutter/material.dart';

class Music extends StatefulWidget {

  @override
  State<Music> createState() => _UploadState();
}

class _UploadState extends State<Music> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("This is Music Page.Music.dart"),
    );
  }
}