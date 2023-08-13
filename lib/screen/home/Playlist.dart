import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/file_model.dart';
import '../playScreen/audio_player_screen.dart';
import '../playScreen/playlist_screen.dart';

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
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,  // AppBar 색상을 검정색으로 변경
        title: Text("플레이리스트 생성"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.add, color: Colors.white),
                        title: Text('플레이리스트 생성', style: TextStyle(color: Colors.white)),
                        onTap: _createPlaylist,
                      ),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.white),
                        title: Text('플레이리스트 삭제', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          // 플레이리스트 삭제 기능을 여기에 구현
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _playlistController,
              decoration: InputDecoration(
                hintText: "새 플레이리스트 이름",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createPlaylist,
              child: Text("플레이리스트 생성"),
              style: ElevatedButton.styleFrom(primary: Colors.green),
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
                        tileColor: Colors.black,
                        title: Text(
                          playlist!.name,
                          style: TextStyle(color: Colors.white),
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
