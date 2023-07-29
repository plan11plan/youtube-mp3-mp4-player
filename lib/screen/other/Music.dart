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

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Music List'),
    ),
    body: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Get.toNamed('/song', arguments: songs[index]);
          },
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(songs[index].coverUrl),
                SizedBox(height: 10),
                Text(songs[index].title, style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 5),
                Text(songs[index].description, style: Theme.of(context).textTheme.subtitle1),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}
