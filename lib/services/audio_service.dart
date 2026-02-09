import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMusicEnabled = true;

  Future<void> init() async {
    // 기본 설정: 반복 재생
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    try {
      // release mode: loop (repeated playback)
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

      // Verify file existence (logical check)
      print('AudioService: Attempting to play assets/audio/DeepSeaOversea.mp3');

      await _bgmPlayer.play(AssetSource('audio/DeepSeaOversea.mp3'));
      await _bgmPlayer.setVolume(0.5);
      print('AudioService: Playback started successfully');
    } catch (e) {
      print('AudioService Error: Could not play background music: $e');
      // Retry logic or fallback could go here
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgmPlayer.stop();
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    if (_isMusicEnabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }
}
