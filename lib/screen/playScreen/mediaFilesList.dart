import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/file_model.dart';
import 'audio_player_screen.dart';
class MediaFilesList extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final Playlist playlist;

  MediaFilesList({required this.mediaFiles, required this.playlist});

  @override
  _MediaFilesListState createState() => _MediaFilesListState();
}

class _MediaFilesListState extends State<MediaFilesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.mediaFiles.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 1.0,
              margin: EdgeInsets.symmetric(vertical: 9.0, horizontal: 14.0),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioPlayerScreen(
                        mediaFiles: widget.mediaFiles,
                        currentIndex: index,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              File(widget.mediaFiles[index].thumbnailPath),
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
                          Text(
                            widget.mediaFiles[index].title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'font4',
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 10),
                          Text(
                              widget.mediaFiles[index].description,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'font5',
                                  fontWeight: FontWeight.w700
                              )),
                        ],
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(top: 18.0, right: 0),
                        child: Text(
                            widget.mediaFiles[index].duration,
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
                          icon: Icon(Icons.more_vert_outlined, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Delete?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 45,
                                      fontFamily: 'font1',
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor: Colors.grey[800],
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                          'Do you want to delete this file?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          )),
                                      onPressed: () {
                                        var playlistBox = Hive.box<Playlist>('playlists');
                                        widget.playlist.mediaFileTitles.remove(widget.mediaFiles[index].title);
                                        playlistBox.put(widget.playlist.name, widget.playlist);
                                        setState(() {
                                          widget.mediaFiles.removeAt(index);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Cancel',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 16,
                                          )),
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
                      offset: Offset(10, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}