import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MyAudioServiceTask extends BackgroundAudioTask {
  final _player = AudioPlayer();
  late AudioProcessingState _skipState;
  late List<MediaItem> _queue;

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // Load the media items into the queue and set the queue for the player.
    _queue = []; // Populate this with your MediaItems
    _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(_queue[index]);
    });
    _player.setAudioSource(ConcatenatingAudioSource(
      children: _queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
    ));
    AudioServiceBackground.setQueue(_queue);
    _player.play();
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSkipToNext() => _player.seekToNext();

  @override
  Future<void> onSkipToPrevious() => _player.seekToPrevious();

// Implement other audio task methods like onStop, onSeekTo, onCustomAction etc.
}
