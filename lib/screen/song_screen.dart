import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import '../models/file_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget Function(BuildContext context) builder;
  SlideUpRoute({required this.builder})
      : super(
    transitionDuration: Duration(milliseconds: 400),
    reverseTransitionDuration: Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) =>
        builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

class SongScreen extends StatefulWidget {
  final MediaFile? mediaFile;
  final int? index;

  const SongScreen({Key? key, this.mediaFile, this.index}) : super(key: key);

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  late AssetsAudioPlayer assetsAudioPlayer;
  int currentMediaFileIndex = 0;
  List<MediaFile> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    openBox();
    assetsAudioPlayer = AssetsAudioPlayer();

    currentMediaFileIndex = mediaFiles.indexOf(Get.arguments ?? widget.mediaFile ?? mediaFiles[0]);

    assetsAudioPlayer.open(
      Playlist(audios: mediaFiles.map((mediaFile) => Audio.network(
        mediaFile.filePath,
        metas: Metas(
          id: mediaFile.title,
          title: mediaFile.title,
          album: mediaFile.description,
          image: MetasImage.network(mediaFile.thumbnailPath),
        ),
      )).toList()),
      autoStart: false,
      respectSilentMode: true,
    );

    assetsAudioPlayer.playlistAudioFinished.listen((event) {
      if (assetsAudioPlayer.currentPosition.value.compareTo(assetsAudioPlayer.current.value!.audio.duration) == 0) {
        onNext();
      }
    });

    assetsAudioPlayer.playOrPause();
  }

  Future openBox() async {
    var box = await Hive.openBox<MediaFile>('mediaFiles');
    setState(() {
      mediaFiles = box.values.where((mediaFile) => mediaFile.fileType == 'audio').toList();
    });
  }

  void onPrevious() {
    if (currentMediaFileIndex > 0) {
      setState(() {
        currentMediaFileIndex--;
      });
      assetsAudioPlayer.playlistPlayAtIndex(currentMediaFileIndex);
    }
  }

  void onNext() {
    if (currentMediaFileIndex < mediaFiles.length - 1) {
      setState(() {
        currentMediaFileIndex++;
      });
      assetsAudioPlayer.playlistPlayAtIndex(currentMediaFileIndex);
    }
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positiondataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration, PositionData>(
        assetsAudioPlayer.currentPosition,
        assetsAudioPlayer.isBuffering.map((isBuffering) => isBuffering ? Duration(seconds: 1) : Duration.zero),
            (position, bufferedPosition) => PositionData(
            position, bufferedPosition),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          Get.back();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          onPrevious();
        } else if (details.primaryVelocity! < 0) {
          onNext();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(mediaFiles[currentMediaFileIndex].thumbnailPath),
                    fit: BoxFit.cover
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                    color: Colors.black54
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    mediaFiles[currentMediaFileIndex].thumbnailPath,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.width - 100,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    mediaFiles[currentMediaFileIndex].title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StreamBuilder<PositionData>(
                  stream: _positiondataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    final position = positionData?.position ?? Duration.zero;
                    return SeekBar(
                      duration: assetsAudioPlayer.current.value?.audio.duration ?? Duration.zero,
                      position: position,
                      onChangeEnd: (newPosition) {
                        assetsAudioPlayer.seek(newPosition);
                      },
                    );
                  },
                ),

                SizedBox(height: 16),
                PlayerButtons(
                  onPrevious: onPrevious,
                  onNext: onNext,
                  assetsAudioPlayer: assetsAudioPlayer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PositionData {
  const PositionData(
      this.position,
      this.bufferedPosition,
      );

  final Duration position;
  final Duration bufferedPosition;
}

class PlayerButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final AssetsAudioPlayer assetsAudioPlayer;

  PlayerButtons({
    required this.onPrevious,
    required this.onNext,
    required this.assetsAudioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: Icon(Icons.skip_previous),
        ),
        StreamBuilder<PlayerState>(
          stream: assetsAudioPlayer.playerState,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            return IconButton(
              onPressed: () {
                playerState == PlayerState.play ? assetsAudioPlayer.pause() : assetsAudioPlayer.play();
              },
              icon: Icon(playerState == PlayerState.play ? Icons.pause : Icons.play_arrow),
            );
          },
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.skip_next),
        ),
      ],
    );
  }
}
