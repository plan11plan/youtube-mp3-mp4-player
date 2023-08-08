// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
//
// import '../../models/file_model.dart';
//
// class AudioPlayerScreen extends StatefulWidget {
//   final List<MediaFile> mediaFiles;
//   final int currentIndex;
//
//   AudioPlayerScreen({required this.mediaFiles, required this.currentIndex});
//
//   @override
//   _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
// }
//
// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   late AudioPlayer _player;
//   int? _currentIndex;
//   late StreamSubscription<Duration?> _durationSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.currentIndex;
//     _player = AudioPlayer();
//     _initializeAndPlay(_currentIndex!);
//     _durationSubscription = _player.durationStream.listen((duration) {
//       setState(() {
//         widget.mediaFiles[_currentIndex!].duration = duration.toString();
//       });
//     });
//   }
//
//   void _initializeAndPlay(int index) async {
//     await _player.setFilePath(widget.mediaFiles[index].filePath);
//     _player.play();
//   }
//
//   void _playNext() {
//     int currentIndex = _currentIndex!;
//     if (currentIndex + 1 < widget.mediaFiles.length) {
//       currentIndex++;
//     } else {
//       currentIndex = 0;
//     }
//     _currentIndex = currentIndex;
//     _initializeAndPlay(_currentIndex!);
//   }
//
//   void _playPrevious() {
//     int currentIndex = _currentIndex!;
//     if (currentIndex - 1 >= 0) {
//       currentIndex--;
//     } else {
//       currentIndex = widget.mediaFiles.length - 1;
//     }
//     _currentIndex = currentIndex;
//     _initializeAndPlay(_currentIndex!);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Audio Player"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(widget.mediaFiles[_currentIndex!].title), // Title 출력
//             SizedBox(height: 20),
//             Text(widget.mediaFiles[_currentIndex!].description), // Description 출력
//             SizedBox(height: 20),
//             Text(widget.mediaFiles[_currentIndex!].duration), // Duration 출력
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.skip_previous),
//                   onPressed: _playPrevious,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.play_arrow),
//                   onPressed: () {
//                     if (_player.playing) {
//                       _player.pause();
//                     } else {
//                       _player.play();
//                     }
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.skip_next),
//                   onPressed: _playNext,
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _player.dispose();
//     _durationSubscription.cancel();
//     super.dispose();
//   }
// }
