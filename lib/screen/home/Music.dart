import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:player/screen/playScreen/audio_player_screen.dart';
import '../../models/file_model.dart';
import '../icon/skyColor.dart';
import '../popup/oneDelete.dart';

class  Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<MediaFile> _filteredMediaFiles = [];
  bool _isLiked = false;  // 좋아요 버튼의 상태를 관리합니다.

  @override
  void initState() {
    super.initState();
    _openHiveBox();
    _searchController.addListener(_onSearchChanged);
  }

  // 2. 추가 버튼을 클릭하면 플레이리스트 선택 다이얼로그가 표시됩니다.
  Future<void> showPlaylistSelectionDialog(BuildContext context, String mediaFileTitle) async {
    var playlistBox = await Hive.openBox<Playlist>('playlists');
    var playlistNames = playlistBox.values.map((playlist) => playlist.name).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add to Playlist',style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: playlistNames.map((playlistName) => ListTile(
                title: Text(playlistName,style: TextStyle(color: Colors.black),),
                onTap: () {
                  addToPlaylist(playlistName, mediaFileTitle);
                  Navigator.of(context).pop();
                },
              )).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// 3. 사용자가 플레이리스트를 선택하면 선택된 플레이리스트에 현재 음악 파일의 제목을 추가합니다.
  void addToPlaylist(String playlistName, String mediaFileTitle) {
    var playlistBox = Hive.box<Playlist>('playlists');
    var selectedPlaylist = playlistBox.values.firstWhere((playlist) => playlist.name == playlistName);

    if (selectedPlaylist != null) {
      if (!selectedPlaylist.mediaFileTitles.contains(mediaFileTitle)) {
        selectedPlaylist.mediaFileTitles.add(mediaFileTitle);
        var key = playlistBox.keyAt(playlistBox.values.toList().indexOf(selectedPlaylist));
        playlistBox.put(key, selectedPlaylist);
      }
    }
  }
  Future<void> _openHiveBox() async {
    if (!Hive.isBoxOpen('mediaFiles')) {
      await Hive.openBox<MediaFile>('mediaFiles');
    }
  }
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _filterMediaFiles(_searchController.text);
    });
  }



  void _filterMediaFiles(String searchText) {
    var box = Hive.box<MediaFile>('mediaFiles');
    _filteredMediaFiles = box.values
        .where((file) =>
    file.fileType == 'audio' &&
        file.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }


  void _cancelSearch() {
    _searchController.clear();
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String title, String fileType) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OneDeleteDialog(
          onDelete: (t, f) => removeAudioFile(t, f), // 수정된 부분
          title: title,
          fileType: fileType,
        );
      },
    );
  }

  void updateFileDetails(String title, String fileType, String newTitle, String newDescription) {
    var box = Hive.box<MediaFile>('mediaFiles');
    var fileToUpdate = box.values.firstWhere((file) => file.title == title && file.fileType == fileType);
    if (fileToUpdate != null) {
      fileToUpdate.title = newTitle;
      fileToUpdate.description = newDescription;
      var key = box.keyAt(box.values.toList().indexOf(fileToUpdate));
      box.put(key, fileToUpdate);
    }
  }


  Future<void> showEditDialog(BuildContext context, String title, String fileType) async {
    final int maxTextLength = 12;
    var box = Hive.box<MediaFile>('mediaFiles');
    var currentFile = box.values.firstWhere((file) => file.title == title && file.fileType == fileType);
    var titleController = TextEditingController(text: currentFile?.title ?? "");
    var descriptionController =
    TextEditingController(text: currentFile?.description ?? "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit File',
            style: TextStyle(
                color: Colors.black, fontSize: 45, fontFamily: 'font1'),
          ),
          contentPadding: EdgeInsets.all(15.0),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.grey[800],
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 20), // 여기서 공간을 추가합니다.
                Text("Title : ",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  maxLength: maxTextLength,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20), // 여기서 공간을 추가합니다.
                Text("Artist : ",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLength: maxTextLength,
                  decoration: InputDecoration(
                    hintText: 'Artist',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
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
              child: Text('Save', style: TextStyle(color: Colors.green)),
              onPressed: () {
                updateFileDetails(currentFile.title, currentFile.fileType, titleController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void removeAudioFile(String title, String fileType) {
    var box = Hive.box<MediaFile>('mediaFiles');
    var fileToDelete = box.values.firstWhere((file) => file.title == title && file.fileType == fileType);
    if (fileToDelete != null) {
      var file = File(fileToDelete.filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      var key = box.keyAt(box.values.toList().indexOf(fileToDelete));
      box.delete(key);
    }
  }
  void updateLikeStatus(String title, String fileType) {
    var box = Hive.box<MediaFile>('mediaFiles');
    var fileToUpdate = box.values.firstWhere((file) => file.title == title && file.fileType == fileType);
    if (fileToUpdate != null) {
      fileToUpdate.like = fileToUpdate.like == 'off' ? 'on' : 'off';
      var key = box.keyAt(box.values.toList().indexOf(fileToUpdate));
      box.put(key, fileToUpdate);
    }
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SkyColor.getColorBoxListenable(),
      builder: (context, Box colorBox, _) {
        SkyColor.colorIndex = colorBox.get('colorIndex', defaultValue: 0);
        return ValueListenableBuilder(
          valueListenable: MoonIconButtonState.getMoonPhaseBoxListenable(),
          builder: (context, Box moonBox, _) {
            MoonIconButtonState.currentPhase =
                moonBox.get('moonPhase', defaultValue: 0);
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                decoration: SkyColor.skyDecoration,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: [
                      SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 19),
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueGrey.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 14,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: "Search the music",
                                    hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontFamily: 'font1',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17),
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      icon: Icon(Icons.search,
                                          size: 23,
                                          color: Colors.white.withOpacity(0.5)),
                                      onPressed: () {},
                                    ),
                                    suffixIcon: _isSearching
                                        ? IconButton(
                                      icon: Icon(Icons.close,
                                          size: 23,
                                          color: Colors.white
                                              .withOpacity(0.5)),
                                      onPressed: _cancelSearch,
                                    )
                                        : null,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _isSearching = value.isNotEmpty;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: MoonIconButton(
                                  callback: () {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box<MediaFile>('mediaFiles').listenable(),
                          builder: (context, Box<MediaFile> box, _) {
                            // 기존에는 _isSearching 조건으로만 필터링하였지만, _isLiked 상태에 따라 좋아요가 눌린 항목만 가져오도록 수정하였습니다.
                            var mediaFiles = _isSearching
                                ? _filteredMediaFiles
                                : (_isLiked
                                ? box.values.where((file) => file.fileType == 'audio' && file.like == 'on').toList()
                                : box.values.where((file) => file.fileType == 'audio').toList());

                            return ListView.builder(
                              itemCount: mediaFiles.length,
                              itemBuilder: (context, index) {
                                return Slidable(
                                  key: Key(mediaFiles[index].title),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) =>
                                            updateLikeStatus(mediaFiles[index].title, mediaFiles[index].fileType),
                                        backgroundColor:
                                        mediaFiles[index].like == 'on'
                                            ? Colors.red.shade300
                                            : Colors.transparent,
                                        foregroundColor:
                                        mediaFiles[index].like == 'on'
                                            ? Colors.white
                                            : Colors.grey,
                                        icon: Icons.favorite,
                                      ),
                                      SlidableAction(
                                        onPressed: (context) => showPlaylistSelectionDialog(context, mediaFiles[index].title),
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.add, // 추가 아이콘
                                      ),
                                      SlidableAction(
                                        onPressed: (context) =>
                                            showEditDialog(context, mediaFiles[index].title, mediaFiles[index].fileType),
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.settings,
                                      ),
                                      SlidableAction(
                                        onPressed: (context) =>
                                            showDeleteConfirmationDialog(context, mediaFiles[index].title, mediaFiles[index].fileType),
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                      ),

                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 1.0,
                                        margin: EdgeInsets.symmetric(vertical: 9.0, horizontal: 35.0),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(15.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.4),
                                              spreadRadius: 0.2,
                                              blurRadius: 3,
                                              offset: Offset(5, 3),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            print("@@@@@ Before Passing to AudioPlayerScreen : @@@@@");
                                            mediaFiles.forEach((file) {
                                              print("${file.title}, ${file.duration}, ..."); // 기타 필요한 메타 정보를 추가하세요
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AudioPlayerScreen(mediaFiles: mediaFiles, currentIndex: index),
                                              ),
                                            );
                                            // 전달 후 mediaFiles의 정보 출력
                                            print("@@@@@@@@@@ After @@@@@@@@@@@@@@@@@@@@@@@@@@@");
                                            mediaFiles.forEach((file) {
                                              print("${file.title}, ${file.duration}, ..."); // 기타 필요한 메타 정보를 추가하세요
                                            });

                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black54.withOpacity(0.4),
                                                            spreadRadius: 4,
                                                            blurRadius: 8,
                                                            offset: Offset(0, 5),
                                                          ),
                                                        ],
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        child: Image.file(
                                                            File(mediaFiles[index].thumbnailPath),
                                                            height: 60,
                                                            width: 60,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    SizedBox(width: 13),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(height: 2),
                                                        Text(mediaFiles[index].title,
                                                            style:  TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 15,
                                                                fontFamily: 'font4',
                                                                fontWeight: FontWeight.w700
                                                            )),
                                                        SizedBox(height: 10),
                                                        Text(
                                                            mediaFiles[index].description,
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontFamily: 'font5',
                                                                fontWeight: FontWeight.w700
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 18.0, right: 0),
                                                  child: Text(
                                                      mediaFiles[index].duration,
                                                      style:TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontFamily: 'font5',
                                                          fontWeight: FontWeight.w700
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 5.0, right: 0),
                                                  child: IconButton(
                                                    icon: Icon(Icons.chevron_left, color: Colors.white),
                                                    onPressed: null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(0, -5),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.7,
                                          margin: EdgeInsets.symmetric(horizontal: 35.0),
                                          height: 5,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                spreadRadius: 1.2,
                                                blurRadius: 8,
                                                offset: Offset(10,2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(
                        height: 180,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: _isLiked ? Colors.red : Colors.white,
                              size: 40.0,
                            ),
                            onPressed: _toggleLike,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}