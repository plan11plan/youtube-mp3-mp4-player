import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../models/song_model.dart';
import '../../widgets/player_buttons.dart';
import '../../widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class SongScreen extends StatefulWidget {
  const SongScreen({Key? key}) : super(key: key);

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  late AudioPlayer audioPlayer;
  int currentSongIndex = Song.songs.indexOf(Get.arguments ?? Song.songs[0]);

  Future<String> copyAssetToTempDirectory(String assetPath) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    ByteData data = await rootBundle.load(assetPath);

    String filePath = '$tempPath/${assetPath.split("/").last}';
    File tempFile = File(filePath);
    await tempFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );

    return filePath;
  }

  Future<List<AudioSource>> copySongsAndGetAudioSources(List<Song> songs) async {
    List<AudioSource> audioSources = [];

    for (Song song in songs) {
      String filePath = await copyAssetToTempDirectory(song.url);
      AudioSource audioSource = AudioSource.uri(
        Uri.parse('file://$filePath'),
      );
      audioSources.add(audioSource);
    }

    return audioSources;
  }

  void onPrevious() {
    if (currentSongIndex > 0) {
      setState(() {
        currentSongIndex--;
      });
    }
  }

  void onNext() {
    if (currentSongIndex < Song.songs.length - 1) {
      setState(() {
        currentSongIndex++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    copySongsAndGetAudioSources(Song.songs).then((audioSources) {
      audioPlayer.setAudioSource(ConcatenatingAudioSource(children: audioSources));
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Stream<SeekBarData> get _seekBarDataSteam =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
          audioPlayer.positionStream, audioPlayer.durationStream, (
          Duration position,
          Duration? duration,
          ) {
        return SeekBarData(position, duration ?? Duration.zero);
      });

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

          // 이미지를 BackdropFilter 위젯 위에 위치시킵니다.
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.asset(Song.songs[currentSongIndex].coverUrl,width: 270.0,
                ),
              ),
              SizedBox(height: 240),
            ],
          ),

          const _BackgroundFilter(),
          _MusicPlayer(
              song: Song.songs[currentSongIndex],
              seekBarDataSteam: _seekBarDataSteam,
              audioPlayer: audioPlayer,
              onPrevious: onPrevious,
              onNext: onNext),
        ],
      ),
    );
  }
}

class _MusicPlayer extends StatelessWidget {
  const _MusicPlayer({
    Key? key,
    required this.song,
    required Stream<SeekBarData> seekBarDataSteam,
    required this.audioPlayer,
    required this.onPrevious,
    required this.onNext,
  })  : _seekBarDataSteam = seekBarDataSteam,
        super(key: key);

  final Song song;
  final Stream<SeekBarData> _seekBarDataSteam;
  final AudioPlayer audioPlayer;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

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
          StreamBuilder<SeekBarData>(
            stream: _seekBarDataSteam,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                position: positionData?.position ?? Duration.zero,
                duration: positionData?.duration ?? Duration.zero,
                onChanged: audioPlayer.seek,
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
              IconButton(
                  iconSize: 35,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.cloud_download,
                    color: Colors.white,
                  )),
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
