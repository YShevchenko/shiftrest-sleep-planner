import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/noise_preset.dart';
import '../../domain/services/noise_service.dart';

/// State management for Dark Room mode.
class DarkRoomProvider extends ChangeNotifier {
  final NoiseService _noiseService;

  bool _isActive = false;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Alarm
  DateTime? _alarmTime;
  bool _alarmSet = false;

  DarkRoomProvider(this._noiseService);

  bool get isActive => _isActive;
  bool get controlsVisible => _controlsVisible;
  DateTime get currentTime => _currentTime;
  bool get alarmSet => _alarmSet;
  DateTime? get alarmTime => _alarmTime;
  NoiseService get noiseService => _noiseService;
  NoiseType get noiseType => _noiseService.currentType;
  double get volume => _noiseService.volume;
  bool get isPlaying => _noiseService.isPlaying;

  void activate() {
    _isActive = true;
    _controlsVisible = true;
    _startClock();
    _scheduleHideControls();
    notifyListeners();
  }

  void deactivate() {
    _isActive = false;
    _controlsVisible = true;
    _noiseService.stop();
    _clockTimer?.cancel();
    _hideTimer?.cancel();
    _alarmSet = false;
    _alarmTime = null;
    notifyListeners();
  }

  void tapScreen() {
    _controlsVisible = true;
    notifyListeners();
    _scheduleHideControls();
  }

  void setNoiseType(NoiseType type) {
    _noiseService.setNoiseType(type);
    if (type != NoiseType.off) {
      _noiseService.play();
    }
    notifyListeners();
  }

  void setVolume(double volume) {
    _noiseService.setVolume(volume);
    notifyListeners();
  }

  void setAlarm(Duration duration) {
    _alarmTime = DateTime.now().add(duration);
    _alarmSet = true;
    notifyListeners();
  }

  void cancelAlarm() {
    _alarmTime = null;
    _alarmSet = false;
    notifyListeners();
  }

  Duration? get timeUntilAlarm {
    if (_alarmTime == null) return null;
    final diff = _alarmTime!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _currentTime = DateTime.now();

      // Check alarm
      if (_alarmSet && _alarmTime != null) {
        if (DateTime.now().isAfter(_alarmTime!)) {
          _alarmSet = false;
          _alarmTime = null;
        }
      }

      notifyListeners();
    });
  }

  void _scheduleHideControls() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      _controlsVisible = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }
}
