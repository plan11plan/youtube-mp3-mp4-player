import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/file_model.dart';
import 'audio_player_screen.dart';

class PlaylistMediaFilesScreen extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final Playlist playlist;

  PlaylistMediaFilesScreen({required this.mediaFiles, required this.playlist});

  @override
  _PlaylistMediaFilesScreenState createState() =>
      _PlaylistMediaFilesScreenState();
}

class _PlaylistMediaFilesScreenState extends State<PlaylistMediaFilesScreen> {
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Playlist"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _PlaylistInformation(playlist: widget.playlist),
                const SizedBox(height: 30),
                _MediaFilesList(mediaFiles: widget.mediaFiles, playlist: widget.playlist),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistInformation extends StatelessWidget {
  final Playlist playlist;

  _PlaylistInformation({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'assets/image/paka.png',
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(
          height: 30,
        ),
        Text(
          playlist.name, // Assuming `name` is the attribute for playlist name in the Playlist model.
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
class _MediaFilesList extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final Playlist playlist;

  _MediaFilesList({required this.mediaFiles, required this.playlist});

  @override
  __MediaFilesListState createState() => __MediaFilesListState();
}

class __MediaFilesListState extends State<_MediaFilesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.mediaFiles.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(
            '${index + 1}',
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          title: Text(
            widget.mediaFiles[index].title,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Artist Info Here', // You can replace this with the artist's name or other info.
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Colors.white70),
          ),

            trailing: IconButton(
              icon: Icon(Icons.more_vert_outlined, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: const Text(
                        'Delete?',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text(
                              'Do you want to delete this file?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
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
        );
      },
    );
  }
}
