import 'package:flutter/material.dart'
    '';

import '../../models/file_model.dart';
class PlayOrShuffleSwitch extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final Function(List<MediaFile>) onShuffle;

  const PlayOrShuffleSwitch({
    Key? key,
    required this.mediaFiles,
    required this.onShuffle,
  }) : super(key: key);

  @override
  State<PlayOrShuffleSwitch> createState() => PlayOrShuffleSwitchState();
}

class PlayOrShuffleSwitchState extends State<PlayOrShuffleSwitch> {
  bool isPlay = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (!isPlay) {
          // Shuffle the playlist
          List<MediaFile> shuffledMediaFiles = List.from(widget.mediaFiles);
          shuffledMediaFiles.shuffle();
          widget.onShuffle(shuffledMediaFiles);
        }
        setState(() {
          isPlay = !isPlay;
        });
      },
      child: Container(
        height: 50,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 30,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: isPlay? 0: width * 0.45,
              child: Container(
                height: 50,
                width: width * 0.45,
                decoration: BoxDecoration(
                    color: Colors.deepPurple.shade400, borderRadius: BorderRadius.circular(15)
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Play',
                          style: TextStyle(
                              color: isPlay ? Colors.white : Colors.deepPurple,
                              fontSize: 17),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.play_circle,
                        color: isPlay ? Colors.white : Colors.deepPurple,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Shuffle',
                          style: TextStyle(
                            color: isPlay ? Colors.deepPurple : Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.shuffle,
                        color: isPlay ? Colors.deepPurple : Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}