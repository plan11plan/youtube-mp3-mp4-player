import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:player/screen/video/video_player_screen.dart';
import '../../models/file_model.dart';

class Video extends StatefulWidget {
  const Video({Key? key}) : super(key: key);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  List<MediaFile> mediaFiles = []; // Initialize as an empty list

  @override
  void initState() {
    super.initState();
    openBox();
  }

  Future openBox() async {
    var files = await MediaFile.loadAllVideoFiles();
    setState(()  {
      mediaFiles = files;
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
    });
  }


  Future<void> showDeleteConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Do you want to delete this video?', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                removeVideoFile(index);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            Colors.deepPurple.shade700.withOpacity(0.99),
            Colors.indigo.shade800.withOpacity(0.76),
            Colors.indigo.shade700.withOpacity(0.76),
            Colors.deepPurple.shade300.withOpacity(0.9),
            Colors.deepPurple.shade200.withOpacity(0.8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.separated(
          itemCount: mediaFiles.length,
          separatorBuilder: (context, index) => Divider(color: Colors.white54),
          itemBuilder: (context, index) {
            return InkWell(
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
    );
  }
}
