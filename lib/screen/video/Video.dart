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
                  style: TextStyle(color: Colors.white),),
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
    return Scaffold(
      backgroundColor: Color(0xFF191414), // Spotify dark black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Videos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: videos.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey),
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
                  Row(
                    children: [
                      // Display video thumbnail
                      Image.asset(videos[index].coverUrl, height: 50, width: 50, fit: BoxFit.cover),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(videos[index].title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(videos[index].description, style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => showDeleteConfirmationDialog(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
