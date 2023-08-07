import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import '../../models/file_model.dart';
import '../icon/skyColor.dart';
import '../popup/oneDelete.dart';
import '../video/video_player_screen.dart';

class Video extends StatefulWidget {
  const Video({Key? key}) : super(key: key);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  List<MediaFile> mediaFiles = [];
  List<MediaFile> filteredMediaFiles = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    openBox();
    _searchController.addListener(_onSearchChanged);
  }

  Future openBox() async {
    var files = await MediaFile.loadAllVideoFiles();
    setState(() {
      mediaFiles = files;
      filteredMediaFiles = mediaFiles;
    });
  }

  void _onSearchChanged() {
    var search = _searchController.text.toLowerCase();
    setState(() {
      filteredMediaFiles = mediaFiles
          .where((file) => file.title.toLowerCase().contains(search))
          .toList();
    });
  }
  void removeVideoFile(int index) async {
    var box = Hive.box<MediaFile>('mediaFiles');
    var fileToDelete = mediaFiles[index];
    var file = File(fileToDelete.filePath);

    if (file.existsSync()) {
      file.deleteSync();
    }

    int hiveIndex = box.values.toList().indexOf(fileToDelete); // Find the index in the Hive box
    if (hiveIndex != -1) {
      box.deleteAt(hiveIndex); // Delete the entry from the Hive box using the found index
    }

    var updatedVideoFiles = await MediaFile.loadAllVideoFiles();
    setState(() {
      mediaFiles = updatedVideoFiles;
      filteredMediaFiles = updatedVideoFiles;

    });
  }

  void _cancelSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      filteredMediaFiles = mediaFiles;
    });
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OneDeleteDialog(
          onDelete: removeVideoFile,
          index: index,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            icon: Icon(Icons.close, size: 23, color: Colors.white.withOpacity(0.5)),
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
                itemCount: filteredMediaFiles.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.white54),
                itemBuilder: (context, index) {
                  return Slidable(
                      key: Key(filteredMediaFiles[index].title),
                  startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: const [
                  // 왼쪽(또는 위쪽)에 표시할 액션을 여기에 추가합니다.
                  ],
                  ),
                  endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                  SlidableAction(
                  onPressed: (context) => showDeleteConfirmationDialog(context, index),
                  backgroundColor: Colors.red.shade300,
                  foregroundColor: Colors.white,
                  icon: Icons.favorite,
                  label: 'like',
                  ),
                  SlidableAction(
                  onPressed: (context) => showDeleteConfirmationDialog(context, index),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  icon: Icons.settings,
                  label: 'set',
                  ),
                  SlidableAction(
                  onPressed: (context) => showDeleteConfirmationDialog(context, index),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'delete',
                  ),
                  ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(url: mediaFiles[index].filePath),
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
                                  child: Image.file(File(filteredMediaFiles[index].thumbnailPath), height: 50, width: 50, fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(filteredMediaFiles[index].title, style: Theme.of(context).textTheme.headline6),
                                  SizedBox(height: 5),
                                  Text(filteredMediaFiles[index].fileType, style: Theme.of(context).textTheme.subtitle1),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
