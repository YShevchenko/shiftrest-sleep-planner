import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/noise_preset.dart';

/// Service for managing noise playback using audioplayers.
class NoiseService extends ChangeNotifier {
  NoisePreset _currentPreset = const NoisePreset(type: NoiseType.off);
  bool _isPlaying = false;

  final AudioPlayer _player = AudioPlayer();

  NoisePreset get currentPreset => _currentPreset;
  bool get isPlaying => _isPlaying;
  NoiseType get currentType => _currentPreset.type;
  double get volume => _currentPreset.volume;

  void setNoiseType(NoiseType type) {
    if (type == NoiseType.off) {
      stop();
      return;
    }
    _currentPreset = _currentPreset.copyWith(type: type);
    if (_isPlaying) {
      _restartPlayback();
    }
    notifyListeners();
  }

  void setVolume(double volume) {
    _currentPreset = _currentPreset.copyWith(volume: volume.clamp(0.0, 1.0));
    _player.setVolume(_currentPreset.volume);
    notifyListeners();
  }

  void play() {
    if (_currentPreset.type == NoiseType.off) return;
    _isPlaying = true;
    _startPlayback();
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _stopPlayback();
    _currentPreset = _currentPreset.copyWith(type: NoiseType.off);
    notifyListeners();
  }

  void toggle() {
    if (_isPlaying) {
      stop();
    } else {
      play();
    }
  }

  String _assetPathForType(NoiseType type) {
    switch (type) {
      case NoiseType.white:
        return 'sounds/white_noise.mp3';
      case NoiseType.brown:
        return 'sounds/brown_noise.mp3';
      case NoiseType.pink:
        return 'sounds/pink_noise.mp3';
      case NoiseType.off:
        return 'sounds/white_noise.mp3';
    }
  }

  void _startPlayback() {
    final path = _assetPathForType(_currentPreset.type);
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(_currentPreset.volume);
    _player.play(AssetSource(path)).catchError((Object e) {
      debugPrint('NoiseService: playback error: $e');
    });
  }

  void _stopPlayback() {
    _player.stop();
  }

  void _restartPlayback() {
    _stopPlayback();
    _startPlayback();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
