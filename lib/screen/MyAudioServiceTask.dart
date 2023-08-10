import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioServiceTask extends BackgroundAudioTask {
  final _player = AudioPlayer();

  // TODO: Add your playback logic

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // 예: _player.setUrl(your_url);
    // _player.play();
  }

  @override
  Future<void> onStop() async {
    await _player.stop();
    await super.onStop();
  }

// 여기에 다른 오버라이드 메서드 (onPlay, onPause, onSkipToNext 등)를 추가하여 로직을 구현할 수 있습니다.
}
