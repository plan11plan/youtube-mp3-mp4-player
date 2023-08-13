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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.add, color: Colors.white),
                          title: Text('Create Playlist', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Text(
                                    'Create Playlist',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextField(
                                        controller: _playlistController,
                                        decoration: InputDecoration(
                                          hintText: "New Playlist Name",
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
                                        onPressed: () {
                                          _createPlaylist();
                                          Navigator.of(context).pop();  // This will close the current dialog
                                          Navigator.of(context).pop();  // This will close the settings dialog
                                        },
                                        child: Text("Create Playlist"),
                                        style: ElevatedButton.styleFrom(primary: Colors.green),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        ListTile(
                          leading: Icon(Icons.delete, color: Colors.white),
                          title: Text('Delete Playlist', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.of(context).pop(); // 현재 모달 팝업을 닫습니다.

                            // 플레이리스트 선택 화면을 표시합니다.
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: const Text(
                                    'Select Playlist to Delete',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Container(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      itemCount: Hive.box<Playlist>('playlists').length,
                                      itemBuilder: (context, index) {
                                        var playlist = Hive.box<Playlist>('playlists').getAt(index);
                                        return ListTile(
                                          title: Text(playlist!.name, style: TextStyle(color: Colors.white)),
                                          onTap: () {
                                            Navigator.of(context).pop(); // 선택 화면을 닫습니다.

                                            // 'Delete?' 팝업창을 표시합니다.
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  title: const Text(
                                                    'Delete?',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text(
                                                          'Do you want to delete this playlist?',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                      onPressed: () {
                                                        Hive.box<Playlist>('playlists').deleteAt(index);
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),



                      ],
                    ),
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
