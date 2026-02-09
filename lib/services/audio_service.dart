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
      await _bgmPlayer.play(AssetSource('audio/DeepSeaOversea.mp3'));
      await _bgmPlayer.setVolume(0.5); // 배경음악 볼륨 조절 (0.0 ~ 1.0)
    } catch (e) {
      print('Error playing background music: $e');
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
