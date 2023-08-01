import 'package:flutter/material.dart';
import 'package:player/screen/video/video_player_screen.dart';
import '../../models/video_model.dart';

class Video extends StatefulWidget {
  const Video({Key? key}) : super(key: key);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  List<downVideo> videos = [];

  @override
  void initState() {
    super.initState();
    videos = downVideo.videos;
  }

  void removeVideo(int index) {
    setState(() {
      videos.removeAt(index);
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
                Text('Do you want to delete this video?',
                  style: TextStyle(color: Colors.black),),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                removeVideo(index);
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
          )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.separated(
          itemCount: videos.length,
          separatorBuilder: (context, index) => Divider(color: Colors.white54),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(url: videos[index].url),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row( // Thumbnail image added to the row
                      children: [
                        Image.asset(videos[index].coverUrl, height: 50, width: 50, fit: BoxFit.cover),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(videos[index].title, style: Theme.of(context).textTheme.headline6),
                            SizedBox(height: 5),
                            Text(videos[index].description, style: Theme.of(context).textTheme.subtitle1),
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
