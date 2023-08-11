import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../models/file_model.dart';
import '../../widgets/player_buttons.dart';
import '../../widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class AudioPlayerScreen extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final int currentIndex;

  const AudioPlayerScreen(
      {Key? key, required this.mediaFiles, required this.currentIndex})
      : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer audioPlayer;
  int currentSongIndex = 0;
  // late StreamSubscription<Duration?> _durationSubscription;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer(); // 추가된 코드

    currentSongIndex = widget.currentIndex;

    audioPlayer.setAudioSource(ConcatenatingAudioSource(
      children: widget.mediaFiles
          .map(
            (mediaFile) => AudioSource.file(
          File(mediaFile.filePath).path,
          tag: MediaItem(
            id: mediaFile.title,
            title: mediaFile.title,
            album: mediaFile.description,
            artUri: Uri.parse(mediaFile.thumbnailPath),
          ),
        ),
      )
          .toList(),
    ));

    audioPlayer?.seek(Duration.zero, index: currentSongIndex);
    audioPlayer?.play();
    audioPlayer?.currentIndexStream.listen((index) {
      if (index != null) {
        setState(() {
          currentSongIndex = index;
        });
      }
    });
  }

//
  void onPrevious() {
    if (currentSongIndex! > 0) {
      setState(() {
        currentSongIndex = currentSongIndex! - 1;
      });
    }
  }

  void onNext() {
    if (currentSongIndex! < widget.mediaFiles.length - 1) {
      setState(() {
        currentSongIndex = currentSongIndex! + 1;
      });
    }
  }

  @override
  void dispose() {
    audioPlayer?.dispose();
    // _durationSubscription.cancel();
    super.dispose();
  }

  Stream<PositionData> get _positiondataStream =>
      rxdart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer?.positionStream ?? Stream.empty(),
        audioPlayer?.bufferedPositionStream ?? Stream.empty(),
        audioPlayer?.durationStream ?? Stream.empty(),
            (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  image: FileImage(
                      File(widget.mediaFiles[currentSongIndex!].thumbnailPath)),
                  fit: BoxFit.cover),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black54),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.file(
                    File(widget.mediaFiles[currentSongIndex!].thumbnailPath),
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  )),
              SizedBox(height: 240),
            ],
          ),
          const _BackgroundFilter(),
          _MusicPlayer(
              mediaFile: widget.mediaFiles[currentSongIndex!],
              positionDataStream: _positiondataStream,
              audioPlayer: audioPlayer!,
              onPrevious: onPrevious,
              onNext: onNext),
        ],
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

class _MusicPlayer extends StatefulWidget {
  const _MusicPlayer({
    Key? key,
    required this.mediaFile,
    required Stream<PositionData> positionDataStream,
    required this.audioPlayer,
    required this.onPrevious,
    required this.onNext,
  })  : _positionDataStream = positionDataStream,
        super(key: key);

  final MediaFile mediaFile;
  final Stream<PositionData> _positionDataStream;
  final AudioPlayer audioPlayer;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  State<_MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<_MusicPlayer> {
  double _volume = 1.0;
  bool showVolumeSlider = false;

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
            widget.mediaFile.title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.mediaFile.description,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          StreamBuilder<PositionData>(
            stream: widget._positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                position: positionData?.position ?? Duration.zero,
                duration: positionData?.duration ?? Duration.zero,
                onChanged: (duration) {
                  widget.audioPlayer.seek(duration);
                },
                onChangeEnd: (duration) {
                  widget.audioPlayer.seek(duration);
                },
              );
            },
          ),
          PlayerButtons(
              audioPlayer: widget.audioPlayer, onPrevious: widget.onPrevious, onNext: widget.onNext),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 35,
                onPressed: () {
                  setState(() {
                    showVolumeSlider = !showVolumeSlider; // 이 줄을 추가하여 슬라이드 바 표시 여부를 토글

                    widget.audioPlayer.setVolume(_volume);
                  });
                },
                icon: Icon(
                  _volume == 0 ? Icons.volume_off : Icons.volume_down,
                  color: Colors.white,
                ),
              ),

              if (showVolumeSlider)  // 슬라이더 표시 여부에 따라 슬라이더를 표시하거나 숨김
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white.withOpacity(0.7),
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white.withOpacity(0.7),
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                          widget.audioPlayer.setVolume(_volume);
                        });
                      },
                    ),
                  ),
                ),

              StreamBuilder<LoopMode>(
                stream: widget.audioPlayer.loopModeStream,
                builder: (context, snapshot) {
                  final loopMode = snapshot.data ?? LoopMode.off;
                  return IconButton(
                    iconSize: 35,
                    onPressed: () {
                      switch (loopMode) {
                        case LoopMode.off:
                          widget.audioPlayer.setLoopMode(LoopMode.one);
                          break;
                        case LoopMode.one:
                          widget.audioPlayer.setLoopMode(LoopMode.all);
                          break;
                        case LoopMode.all:
                        default:
                          widget.audioPlayer.setLoopMode(LoopMode.off);
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

