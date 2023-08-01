import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/song_model.dart';
import '../widgets/player_buttons.dart';
import '../widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class SongScreen extends StatefulWidget {
  final Song? song;

  const SongScreen({Key? key, this.song}) : super(key: key);

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  late AudioPlayer audioPlayer;
  int currentSongIndex = 0;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    currentSongIndex = Song.songs.indexOf(Get.arguments ?? widget.song ?? Song.songs[0]);

    audioPlayer.setAudioSource(ConcatenatingAudioSource(
      children: Song.songs.map((song) => AudioSource.uri(
        Uri.parse('asset:///${song.url}'),
        tag: MediaItem(
          id: song.title,
          title: song.title,
          album: song.description,
          artUri: Uri.parse('asset:///${song.coverUrl}'),
        ),
      )).toList(),
    ));

    audioPlayer.seek(Duration.zero, index: currentSongIndex);
    audioPlayer.play();

    audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        setState(() {
          currentSongIndex = index;
        });
      }
    });
  }

  void onPrevious() {
    if (currentSongIndex > 0) {
      setState(() {
        currentSongIndex--;
      });
      audioPlayer.seek(Duration.zero, index: currentSongIndex);
    }
  }

  void onNext() {
    if (currentSongIndex < Song.songs.length - 1) {
      setState(() {
        currentSongIndex++;
      });
      audioPlayer.seek(Duration.zero, index: currentSongIndex);
    }
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positiondataStream =>
      rxdart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
            (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    image: AssetImage(Song.songs[currentSongIndex].coverUrl),
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
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset(Song.songs[currentSongIndex].coverUrl,width: 270.0,),
                ),
                SizedBox(height: 240),
              ],
            ),
            const _BackgroundFilter(),
            _MusicPlayer(
                song: Song.songs[currentSongIndex],
                positionDataStream: _positiondataStream,
                audioPlayer: audioPlayer,
                onPrevious: onPrevious,
                onNext: onNext),
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
      this.duration,
      );

  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class _MusicPlayer extends StatelessWidget {
  const _MusicPlayer({
    Key? key,
    required this.song,
    required Stream<PositionData> positionDataStream,
    required this.audioPlayer,
    required this.onPrevious,
    required this.onNext,
  })  : _positionDataStream = positionDataStream,
        super(key: key);

  final Song song;
  final Stream<PositionData> _positionDataStream;
  final AudioPlayer audioPlayer;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  Icon _getLoopIcon(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.all:
        return Icon(Icons.repeat_outlined, color: Colors.white);
      case LoopMode.one:
        return Icon(Icons.repeat_one, color: Colors.white);
      case LoopMode.off:
      default:
        return Icon(Icons.repeat_one, color: Colors.grey);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            song.description,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                position: positionData?.position ?? Duration.zero,
                duration: positionData?.duration ?? Duration.zero,
                onChanged: (duration) {
                  audioPlayer.seek(duration);
                },
                onChangeEnd: (duration) {
                  audioPlayer.seek(duration);
                },
              );
            },
          ),
          PlayerButtons(
              audioPlayer: audioPlayer,
              onPrevious: onPrevious,
              onNext: onNext),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  iconSize: 35,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  )),
              StreamBuilder<LoopMode>(
                stream: audioPlayer.loopModeStream,
                builder: (context, snapshot) {
                  final loopMode = snapshot.data ?? LoopMode.off;
                  return IconButton(
                    iconSize: 35,
                    onPressed: () {
                      switch (loopMode) {
                        case LoopMode.off:
                          audioPlayer.setLoopMode(LoopMode.one);
                          break;
                        case LoopMode.one:
                          audioPlayer.setLoopMode(LoopMode.all);
                          break;
                        case LoopMode.all:
                        default:
                          audioPlayer.setLoopMode(LoopMode.off);
                          break;
                      }
                    },
                    icon: _getLoopIcon(loopMode),
                  );
                },
              ),

            ],
          )
        ],
      ),
    );
  }
}

class _BackgroundFilter extends StatelessWidget {
  const _BackgroundFilter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.0),
            ],
            stops: [
              0.0,
              0.4,
              0.6
            ]).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.grey,
              ],
            )),
      ),
    );
  }
}
