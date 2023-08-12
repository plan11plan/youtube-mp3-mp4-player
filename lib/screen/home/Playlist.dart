import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/file_model.dart';
import '../playScreen/audio_player_screen.dart';

class PlaylistCreationScreen extends StatefulWidget {
  @override
  _PlaylistCreationScreenState createState() => _PlaylistCreationScreenState();
}

class _PlaylistCreationScreenState extends State<PlaylistCreationScreen> {
  TextEditingController _playlistController = TextEditingController();

  void _createPlaylist() {
    if (_playlistController.text.isNotEmpty) {
      var playlistBox = Hive.box<Playlist>('playlists');
      var newPlaylist = Playlist(name: _playlistController.text, mediaFileTitles: []);
      playlistBox.add(newPlaylist);
      _playlistController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("플레이리스트 생성"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _playlistController,
              decoration: InputDecoration(
                hintText: "새 플레이리스트 이름",
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createPlaylist,
              child: Text("플레이리스트 생성"),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Playlist>('playlists').listenable(),
                builder: (context, Box<Playlist> box, _) {
                  return ListView.builder(
                    itemCount: box.values.length,
                    itemBuilder: (context, index) {
                      var playlist = box.getAt(index);
                      return ListTile(
                        title: Text(
                          playlist!.name,
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () async {
                          var mediaFilesBox = Hive.box<MediaFile>('mediaFiles');
                          List<MediaFile> playlistMediaFiles = playlist.mediaFileTitles
                              .map((title) => mediaFilesBox.values.firstWhere((file) => file.title == title))
                              .toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistMediaFilesScreen(mediaFiles: playlistMediaFiles, playlist: playlist),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            box.deleteAt(index);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistMediaFilesScreen extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final Playlist playlist;

  PlaylistMediaFilesScreen({required this.mediaFiles, required this.playlist});

  @override
  _PlaylistMediaFilesScreenState createState() => _PlaylistMediaFilesScreenState();
}

class _PlaylistMediaFilesScreenState extends State<PlaylistMediaFilesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("플레이리스트 음악"),
      ),
      body: ListView.builder(
        itemCount: widget.mediaFiles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              widget.mediaFiles[index].title,
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioPlayerScreen(mediaFiles: widget.mediaFiles, currentIndex: index),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  var playlistBox = Hive.box<Playlist>('playlists');
                  widget.playlist.mediaFileTitles.remove(widget.mediaFiles[index].title);
                  playlistBox.put(widget.playlist.name, widget.playlist);
                  widget.mediaFiles.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }
}

// AudioPlayerScreen 코드는 이전에 제공한 코드를 그대로 사용하면 됩니다.
