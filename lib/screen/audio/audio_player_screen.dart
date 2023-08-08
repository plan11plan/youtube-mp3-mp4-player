import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/file_model.dart';

class AudioPlayerScreen extends StatefulWidget {
  final MediaFile mediaFile;

  AudioPlayerScreen({required this.mediaFile});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.mediaFile.filePath); // isLocal: true를 제거

    // _audioPlayer.onDurationChanged.listen((event) {
    //   setState(() => _duration = event.duration);
    // });
    //
    // _audioPlayer.onAudioPositionChanged.listen((Duration p) {
    //   setState(() => _position = p);
    // });
    //
    // _audioPlayer.onPlayerCompletion.listen((_) {
    //   setState(() {
    //     _position = _duration;
    //     _isPlaying = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Now Playing', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Image.file(
                File(widget.mediaFile.thumbnailPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Slider(
            value: _position.inMilliseconds.toDouble(),
            onChanged: (value) {
              final newPosition = Duration(milliseconds: value.toInt());
              _audioPlayer.seek(newPosition);
            },
            min: 0.0,
            max: _duration.inMilliseconds.toDouble(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Utils.formatDuration(_position),
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  Utils.formatDuration(_duration),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white),
                iconSize: 40,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 60,
                onPressed: () {
                  if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    // _audioPlayer.play(widget.mediaFile.filePath); // isLocal: true를 제거
                  }
                  setState(() {
                    _isPlaying = !_isPlaying;
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
          SizedBox(height: 50),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }
}

class Utils {
  static String formatDuration(Duration d) {
    final ms = d.inMilliseconds;
    int second = (ms / 1000).floor() % 60;
    int minute = (ms / (1000 * 60)).floor() % 60;
    int hour = (ms / (1000 * 60 * 60)).floor();

    String format(int n) {
      return n < 10 ? '0$n' : n.toString();
    }

    return "$hour:${format(minute)}:${format(second)}";
  }
}
