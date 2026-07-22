import 'package:audioplayers/audioplayers.dart';

class PuzzleAudioService {
  PuzzleAudioService._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _isMuted = false;
  static String? _currentTrack;

  static bool get isMuted => _isMuted;
  static String? get currentTrack => _currentTrack;

  static Future<void> setMuted(bool value) async {
    _isMuted = value;
    if (_isMuted) {
      await _player.stop();
      _currentTrack = null;
    }
  }

  static Future<void> playWinSound() async {
    if (_isMuted) return;
    _currentTrack = 'win';
    await _player.stop();
    await _player.play(AssetSource('audio/puzzle_win.mp3'));
  }

  static Future<void> stopWinSound() async {
    if (_currentTrack == 'win') {
      await _player.stop();
      _currentTrack = null;
    }
  }

  static Future<void> playRewardSound() async {
    if (_isMuted) return;
    _currentTrack = 'reward';
    await _player.stop();
    await _player.play(AssetSource('audio/puzzle_reward.mp3'));
  }

  static Future<void> playClickSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('audio/puzzle_click.mp3'));
  }

  static Future<void> playSuccessSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('audio/puzzle_success.mp3'));
  }

  static Future<void> playFailSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('audio/puzzle_fail.mp3'));
  }

  static Future<void> playBackgroundMusic() async {
    if (_isMuted) return;
    if (_currentTrack == 'bgm') return;
    _currentTrack = 'bgm';
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/puzzle_bgm.mp3'));
  }

  static Future<void> stopBackgroundMusic() async {
    if (_currentTrack == 'bgm') {
      await _player.stop();
      _currentTrack = null;
    }
  }

  static Future<void> stopAll() async {
    await _player.stop();
    _currentTrack = null;
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}