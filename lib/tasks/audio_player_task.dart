import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song_model.dart';

void audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _player = AudioPlayer();
  late final List<Song> _songQueue;
  int _songIndex = 0;

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    _songQueue = Song.songs; // Assuming Song.songs is your list of songs.
    await _player.setUrl(_songQueue[_songIndex].url);
    _player.play();
  }

  @override
  Future<void> onStop() async {
    await _player.stop();
    await super.onStop();
  }

  @override
  onPlay() => _player.play();

  @override
  onPause() => _player.pause();

  @override
  Future<void> onSkipToNext() async {
    _songIndex++;
    if (_songIndex >= _songQueue.length) _songIndex = 0;
    await _player.setUrl(_songQueue[_songIndex].url);
    _player.play();
  }

  @override
  Future<void> onSkipToPrevious() async {
    _songIndex--;
    if (_songIndex < 0) _songIndex = _songQueue.length - 1;
    await _player.setUrl(_songQueue[_songIndex].url);
    _player.play();
  }
}
