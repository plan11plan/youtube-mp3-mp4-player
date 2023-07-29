import 'package:flutter/material.dart';

class Video extends StatefulWidget {

  @override
  State<Video> createState() => _UploadState();
}

class _UploadState extends State<Video> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade800.withOpacity(0.8),
              Colors.deepPurple.shade200.withOpacity(0.8),
            ],
          )),
      child: Scaffold(
        backgroundColor: Colors.transparent,

      ),
    );
  }
}