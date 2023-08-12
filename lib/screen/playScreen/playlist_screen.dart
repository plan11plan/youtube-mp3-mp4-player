// playlist_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/file_model.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;

  PlaylistScreen({required this.playlist});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<MediaFile>('mediaFiles').listenable(),
        builder: (context, Box<MediaFile> box, _) {
          List<MediaFile> playlistMediaFiles = widget.playlist.mediaFileTitles
              .map((title) => box.values.firstWhere((file) => file.title == title))
              .toList();

          return ListView.builder(
            itemCount: playlistMediaFiles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(playlistMediaFiles[index].title),
                // ... 다른 기능들(재생, 삭제 등)을 추가하실 수 있습니다.
              );
            },
          );
        },
      ),
    );
  }
}
