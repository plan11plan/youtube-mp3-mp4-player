import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/file_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediaFile mediaFile;

  VideoPlayerScreen({required this.mediaFile});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.mediaFile.filePath))
      ..initialize().then((_) {
        setState(() {}); // Ensure widget is rebuilt when video is ready to be played
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Now Playing', style: TextStyle(color: Colors.white)),
            centerTitle: true,
          ),
          _controller.value.isInitialized
              ? Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          )
              : CircularProgressIndicator(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  widget.mediaFile.title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.mediaFile.description,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.skip_previous, color: Colors.white),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    color: Colors.white,
                    iconSize: 60,
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, color: Colors.white),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
