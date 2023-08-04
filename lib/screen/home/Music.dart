
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/file_model.dart';
import '../../widgets/skyColors.dart';
import '../popup/oneDelete.dart';
import '../song_screen.dart';

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  List<MediaFile> mediaFiles = []; //1. mediaFiles 초기화

  @override
  void initState() {
    super.initState();
    openBox(); //2.가장 먼저 할일!  mediaFiles에 가져올거임
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

    int hiveIndex = box.values.toList().indexOf(fileToDelete); // Find the index in the Hive box
    if (hiveIndex != -1) {
      box.deleteAt(hiveIndex); // Delete the entry from the Hive box using the found index
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SkyColors.skyDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.separated(
          itemCount: mediaFiles.length,
          separatorBuilder: (context, index) => Divider(color: Colors.white54),
          itemBuilder: (context, index) { //itemBuilder: (context, index): 이는 각 항목을 만드는 빌더 함수입니다. 이 경우, 각 항목은 InkWell 위젯입니다
            return InkWell(//InkWell은 머티리얼 디자인에서 "잉크 트림" 효과를 제공하는 위젯입니다. 이 효과는 위젯을 탭할 때 시각적인 피드백을 사용자에게 제공합니다.
              onTap: () {
                Navigator.push( // Navigator.push를 사용하여 새로운 화면을 표시합니다.
                  context,
                  MaterialPageRoute(// MaterialPageRoute는 애니메이션과 함께 새로운 화면을 표시하는 라우트입니다.
                    builder: (context) => SongScreen(mediaFile: mediaFiles[index],index: index), //Changed to AudioPlayerScreen
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
