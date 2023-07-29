import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/song_model.dart';

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    songs = Song.songs;
  }

  void removeSong(int index) {
    setState(() {
      songs.removeAt(index);
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
                Text('Do you want to delete this song?',
                style: TextStyle(color: Colors.black),),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                removeSong(index);
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
              Colors.deepPurple.shade200.withOpacity(0.8),
            ],
          )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.separated(
          itemCount: songs.length,
          separatorBuilder: (context, index) => Divider(color: Colors.white54),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Get.toNamed('/song', arguments: songs[index]);
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(songs[index].title, style: Theme.of(context).textTheme.headline6),
                        SizedBox(height: 5),
                        Text(songs[index].description, style: Theme.of(context).textTheme.subtitle1),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
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
