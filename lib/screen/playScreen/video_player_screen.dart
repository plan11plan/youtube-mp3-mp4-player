import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/file_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final int currentIndex;

  const VideoPlayerScreen(
      {Key? key, required this.mediaFiles, required this.currentIndex})
      : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoPlayer;
  int currentSongIndex = 0;

  @override
  void initState() {
    super.initState();
    currentSongIndex = widget.currentIndex;
    _initializeVideoPlayer(widget.mediaFiles[currentSongIndex].filePath);
  }

  _initializeVideoPlayer(String path) {
    videoPlayer = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        setState(() {});
        videoPlayer.play();
      });
    // 1. videoPlayer에 리스너 추가
    videoPlayer.addListener(_updateSlider);
  }
  void _updateSlider() {
    // 비디오의 현재 위치가 변경될 때마다 setState를 호출하여 UI를 업데이트합니다.
    setState(() {});
  }
  void onPrevious() {
    if (currentSongIndex > 0) {
      setState(() {
        currentSongIndex--;
        videoPlayer.pause();
        videoPlayer.seekTo(Duration.zero);
        _initializeVideoPlayer(widget.mediaFiles[currentSongIndex].filePath);
      });
    }
  }

  void onNext() {
    if (currentSongIndex < widget.mediaFiles.length - 1) {
      setState(() {
        currentSongIndex++;
        videoPlayer.pause();
        videoPlayer.seekTo(Duration.zero);
        _initializeVideoPlayer(widget.mediaFiles[currentSongIndex].filePath);
      });
    }
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                videoPlayer.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: videoPlayer.value.aspectRatio,
                  child: VideoPlayer(videoPlayer),
                )
                    : Center(child: CircularProgressIndicator()),
                SizedBox(height: 20),
                Text(
                  widget.mediaFiles[currentSongIndex].title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  widget.mediaFiles[currentSongIndex].description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 18),
                ),
              ],
            ),
          ),
          if (videoPlayer.value.isInitialized)
            Slider(
              value: videoPlayer.value.position.inSeconds.toDouble(),
              onChanged: (value) {
                final position = Duration(seconds: value.toInt());
                videoPlayer.seekTo(position);
                setState(() {});
              },
              min: 0,
              max: videoPlayer.value.duration.inSeconds.toDouble(),
            ),
          if (videoPlayer.value.isInitialized)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _formatDuration(videoPlayer.value.position),
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    _formatDuration(videoPlayer.value.duration),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white),
                iconSize: 40,
                onPressed: onPrevious,
              ),
              IconButton(
                icon: Icon(videoPlayer.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow),
                color: Colors.white,
                iconSize: 60,
                onPressed: () {
                  setState(() {
                    if (videoPlayer.value.isPlaying) {
                      videoPlayer.pause();
                    } else {
                      videoPlayer.play();
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.white),
                iconSize: 40,
                onPressed: onNext,
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayer.dispose();
  }
}
