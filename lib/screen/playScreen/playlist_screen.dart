import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:player/screen/playScreen/shuffle.dart';
import '../../models/file_model.dart';
import 'audio_player_screen.dart';
import 'mediaFilesList.dart';

class PlaylistMediaFilesScreen extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final Playlist playlist;

  PlaylistMediaFilesScreen({required this.mediaFiles, required this.playlist});

  @override
  _PlaylistMediaFilesScreenState createState() => _PlaylistMediaFilesScreenState();
}

class _PlaylistMediaFilesScreenState extends State<PlaylistMediaFilesScreen> {
  late List<MediaFile> _displayedMediaFiles;

  @override
  void initState() {
    super.initState();
    _displayedMediaFiles = widget.mediaFiles;
  }

  void _onShuffle(List<MediaFile> shuffledList) {
    setState(() {
      _displayedMediaFiles = shuffledList;
    });
  }

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Playlist"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(27.0),
            child: Column(
              children: [
                _PlaylistInformation(playlist: widget.playlist),
                const SizedBox(height: 15),
                PlayOrShuffleSwitch(
                  mediaFiles: widget.mediaFiles,
                  onShuffle: _onShuffle,
                ),
                const SizedBox(height: 10),
                MediaFilesList(
                    mediaFiles: _displayedMediaFiles, playlist: widget.playlist),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistInformation extends StatelessWidget {
  final Playlist playlist;

  _PlaylistInformation({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'assets/image/default_playlist.png',
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          playlist
              .name, // Assuming `name` is the attribute for playlist name in the Playlist model.
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
