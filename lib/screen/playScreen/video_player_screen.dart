import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/file_model.dart';
import '../../widgets/seekbar.dart';

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
  VideoPlayerController? videoPlayer;
  int currentSongIndex = 0;

  @override
  void initState() {
    super.initState();

    currentSongIndex = widget.currentIndex;

    _initializeVideoPlayer(widget.mediaFiles[currentSongIndex].filePath);

    videoPlayer?.addListener(_videoPlayerListener);
  }
  _initializeVideoPlayer(String path) {
    if (videoPlayer?.value.isInitialized ?? false) {
      videoPlayer?.removeListener(_videoPlayerListener);  // Remove listener first
      videoPlayer?.dispose();
    }

    videoPlayer = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        setState(() {});
        videoPlayer?.play();
      });

    videoPlayer?.addListener(_videoPlayerListener);
  }

  void onPrevious() {
    if (currentSongIndex > 0) {
      videoPlayer?.removeListener(_videoPlayerListener);  // Remove listener before switching
      setState(() {
        currentSongIndex--;
        videoPlayer?.pause();
        videoPlayer?.seekTo(Duration.zero);
        _initializeVideoPlayer(widget.mediaFiles[currentSongIndex].filePath);
      });
    }
  }

  void onNext() {
    if (currentSongIndex < widget.mediaFiles.length - 1) {
      videoPlayer?.removeListener(_videoPlayerListener);  // Remove listener before switching
      setState(() {
        currentSongIndex++;
        videoPlayer?.pause();
        videoPlayer?.seekTo(Duration.zero);
        _initializeVideoPlayer(widget.mediaFiles[currentSongIndex].filePath);
      });
    }
  }


  _videoPlayerListener() {
    // If the video has finished playing, play the next video
    if (videoPlayer?.value.position == videoPlayer?.value.duration) {
      onNext();
    }
    setState(() {});
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
                videoPlayer?.value.isInitialized ?? false
                    ? AspectRatio(
                  aspectRatio: videoPlayer!.value.aspectRatio,
                  child: VideoPlayer(videoPlayer!),
                )
                    : CircularProgressIndicator(),
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
          if (videoPlayer?.value.isInitialized ?? false)
            SeekBar(
              position: videoPlayer!.value.position,
              duration: videoPlayer!.value.duration,
              onChanged: (position) {
                videoPlayer?.seekTo(position);
              },
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
                icon: Icon(
                    videoPlayer?.value.isPlaying ?? false
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white),
                iconSize: 60,
                onPressed: () {
                  setState(() {
                    if (videoPlayer?.value.isPlaying ?? false) {
                      videoPlayer?.pause();
                    } else {
                      videoPlayer?.play();
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

  @override
  void dispose() {
    videoPlayer?.removeListener(_videoPlayerListener);
    videoPlayer?.dispose();
    super.dispose();
  }
}
