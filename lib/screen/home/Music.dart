import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/file_model.dart';
import '../icon/skyColor.dart';
import '../popup/oneDelete.dart';
import '../song_screen.dart';

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  List<MediaFile> mediaFiles = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    openBox();
  }

  Future openBox() async {
    var files = await MediaFile.loadAllAudioFiles();
    setState(()  {
      mediaFiles = files;
    });
  }

  void removeAudioFile(int index) async {
    var box = Hive.box<MediaFile>('mediaFiles');
    var fileToDelete = mediaFiles[index];
    var file = File(fileToDelete.filePath);

    if (file.existsSync()) {
      file.deleteSync();
    }

    int hiveIndex = box.values.toList().indexOf(fileToDelete);
    if (hiveIndex != -1) {
      box.deleteAt(hiveIndex);
    }

    var updatedAudioFiles = await MediaFile.loadAllAudioFiles();
    setState(() {
      mediaFiles = updatedAudioFiles;
    });
  }

  Future<void> showDeleteConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OneDeleteDialog(
          onDelete: removeAudioFile,
          index: index,
        );
      },
    );
  }

  void _cancelSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    // You may want to clear your search results here as well, if applicable
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.2),
                            spreadRadius: 4,
                            blurRadius: 14,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: (text) {
                          setState(() {
                            _isSearching = text.isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search the music",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search, size: 23, color: Colors.white.withOpacity(0.5)),
                            onPressed: () {},
                          ),
                          suffixIcon: _isSearching
                              ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white),
                            onPressed: _cancelSearch,
                          )
                              : null,

                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
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
              child: ListView.separated(
                itemCount: mediaFiles.length,
                separatorBuilder: (context, index) => Divider(color: Colors.white54),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongScreen(mediaFile: mediaFiles[index],index: index),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row( // Thumbnail image added to the row
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(5.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Image.file(File(mediaFiles[index].thumbnailPath), height: 50, width: 50, fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(mediaFiles[index].title, style: Theme.of(context).textTheme.headline6),
                                  SizedBox(height: 5),
                                  Text(mediaFiles[index].fileType, style: Theme.of(context).textTheme.subtitle1),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () => showDeleteConfirmationDialog(index),
                          ),
                        ],
                      ),
                    ),
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
