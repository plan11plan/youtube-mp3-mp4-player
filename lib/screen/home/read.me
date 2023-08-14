import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/file_model.dart';
import '../icon/skyColor.dart';
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
      var newPlaylist =
          Playlist(name: _playlistController.text, mediaFileTitles: []);
      playlistBox.add(newPlaylist);
      _playlistController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Playlist"),
        actions: [
          IconButton(
              icon: Icon(Icons.more_vert_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Settings',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 45,
                            fontFamily: 'font1'),
                      ),
                      contentPadding: EdgeInsets.all(15.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      backgroundColor: Colors.grey[800],
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.add, color: Colors.white),
                            title: Text('Create Playlist',
                                style: TextStyle(color: Colors.white)),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Create Playlist',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 45,
                                          fontFamily: 'font1'),
                                    ),
                                    contentPadding: EdgeInsets.all(15.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    backgroundColor: Colors.grey[800],
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextField(
                                          controller: _playlistController,
                                          decoration: InputDecoration(
                                            hintText: "New Playlist Name",
                                            hintStyle: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6)),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white
                                                      .withOpacity(0.3)),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼들 사이에 공간을 균등하게 배분
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _createPlaylist();
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Create Playlist"),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.green),
                                            ),
                                            SizedBox(width: 10), // 두 버튼 사이의 간격
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel"),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.red), // 원하시는 색상으로 변경 가능
                                            ),
                                          ],
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
                            title: Text('Delete Playlist',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            onTap: () {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Select Playlist to Delete',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 45,
                                          fontFamily: 'font1'),
                                    ),
                                    contentPadding: EdgeInsets.all(15.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    backgroundColor: Colors.grey[800],
                                    content: Container(
                                      height: 200,
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        itemCount:
                                            Hive.box<Playlist>('playlists')
                                                .length,
                                        itemBuilder: (context, index) {
                                          var playlist =
                                              Hive.box<Playlist>('playlists')
                                                  .getAt(index);
                                          return ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 8),
                                            title: Text(playlist!.name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18)),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Delete?',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 45,
                                                          fontFamily: 'font1'),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0)),
                                                    backgroundColor:
                                                        Colors.grey[800],
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ListBody(
                                                        children: <Widget>[
                                                          Text(
                                                            'Do you want to delete this playlist?',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text('Delete',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 16)),
                                                        onPressed: () {
                                                          var playlistBox = Hive.box<Playlist>('playlists');
                                                          playlistBox.deleteAt(index);
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text('Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[400],
                                                                fontSize: 16)),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
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
                                        child: Text('Cancel',
                                            style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 16)),
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
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 16)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
      ),

        body: Container(
          decoration: SkyColor.skyDecoration,
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<Playlist>('playlists').listenable(),
                  builder: (context, Box<Playlist> box, _) {
                    return ListView.builder(
                      itemCount: box.values.length,
                      itemBuilder: (context, index) {
                        var playlist = box.getAt(index);
                        return Slidable(
                          key: ValueKey(index),
                          startActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: const [],
                          ),
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  // 플레이리스트 삭제 확인을 위한 대화상자 표시
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Delete?',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 45,
                                              fontFamily: 'font1'),
                                        ),
                                        contentPadding: EdgeInsets.all(15.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0)),
                                        backgroundColor: Colors.grey[800],
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(
                                                'Do you want to delete this playlist?',
                                                style: TextStyle(color: Colors.white, fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Delete',
                                                style: TextStyle(color: Colors.red, fontSize: 16)),
                                            onPressed: () {
                                              var playlistBox = Hive.box<Playlist>('playlists');
                                              playlistBox.deleteAt(index);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Cancel',
                                                style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),

                              SlidableAction(
                                onPressed: (context) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      final _editController = TextEditingController(text: playlist!.name);
                                      return AlertDialog(
                                        title: Text(
                                          'Edit Playlist Name',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 45,
                                              fontFamily: 'font1'),
                                        ),
                                        contentPadding: EdgeInsets.all(15.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0)),
                                        backgroundColor: Colors.grey[800],
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              TextField(
                                                controller: _editController,
                                                decoration: InputDecoration(
                                                  hintText: "Edit Playlist Name",
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
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel',
                                                style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Save',
                                                style: TextStyle(color: Colors.green, fontSize: 16)),
                                            onPressed: () {
                                              var editedPlaylist = playlist.copyWith(name: _editController.text);
                                              box.putAt(index, editedPlaylist);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),



                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                title: Text(
                                  playlist!.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${playlist.mediaFileTitles.length} songs',
                                  style: TextStyle(color: Colors.white54, fontSize: 18),
                                ),
                                trailing: Icon(Icons.chevron_left,
                                    color: Colors.white54, size: 30),
                                onTap: () async {
                                  var mediaFilesBox = Hive.box<MediaFile>('mediaFiles');
                                  List<MediaFile> playlistMediaFiles = playlist
                                      .mediaFileTitles
                                      .map((title) => mediaFilesBox.values
                                      .firstWhere((file) => file.title == title))
                                      .toList();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaylistMediaFilesScreen(
                                          mediaFiles: playlistMediaFiles,
                                          playlist: playlist),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        )








      //
    );
  }
}
