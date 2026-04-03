import 'package:flutter/foundation.dart';
import '../../domain/models/shift.dart';
import '../../domain/repositories/shift_repository.dart';
import '../../domain/services/alarm_service.dart';

/// State management for shifts.
class ShiftProvider extends ChangeNotifier {
  final ShiftRepository _repository;
  final AlarmService _alarmService;

  List<Shift> _shifts = [];
  bool _isLoading = false;
  String? _error;

  ShiftProvider(this._repository, this._alarmService);

  List<Shift> get shifts => _shifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Shifts sorted by start time.
  List<Shift> get sortedShifts => List<Shift>.from(_shifts)
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  /// Get shifts for a specific date.
  List<Shift> shiftsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _shifts.where((s) {
      final shiftDate = DateTime(s.date.year, s.date.month, s.date.day);
      return shiftDate == dateOnly;
    }).toList();
  }

  /// Get shifts in a range.
  List<Shift> shiftsInRange(DateTime start, DateTime end) {
    return _shifts.where((s) {
      return !s.date.isBefore(start) && !s.date.isAfter(end);
    }).toList();
  }

  /// Get the next upcoming shift.
  Shift? get nextShift {
    final now = DateTime.now();
    final upcoming = sortedShifts.where((s) => s.startTime.isAfter(now));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Future<void> loadShifts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shifts = await _repository.getAllShifts();
    } catch (e) {
      _error = 'Failed to load shifts: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadShiftsInRange(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    try {
      _shifts = await _repository.getShiftsInRange(start, end);
    } catch (e) {
      _error = 'Failed to load shifts: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addShift(Shift shift) async {
    try {
      await _repository.insertShift(shift);
      _shifts.add(shift);
      notifyListeners();
      _scheduleWindDown(shift);
    } catch (e) {
      _error = 'Failed to add shift: $e';
      notifyListeners();
    }
  }

  Future<void> updateShift(Shift shift) async {
    try {
      await _repository.updateShift(shift);
      final index = _shifts.indexWhere((s) => s.id == shift.id);
      if (index >= 0) {
        _shifts[index] = shift;
        notifyListeners();
      }
      _scheduleWindDown(shift);
    } catch (e) {
      _error = 'Failed to update shift: $e';
      notifyListeners();
    }
  }

  Future<void> deleteShift(String id) async {
    try {
      await _repository.deleteShift(id);
      _shifts.removeWhere((s) => s.id == id);
      notifyListeners();
      await _alarmService.cancelWindDownNotification();
    } catch (e) {
      _error = 'Failed to delete shift: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAllShifts() async {
    try {
      await _repository.deleteAllShifts();
      _shifts.clear();
      notifyListeners();
      await _alarmService.cancelWindDownNotification();
    } catch (e) {
      _error = 'Failed to delete shifts: $e';
      notifyListeners();
    }
  }

  /// Schedule a wind-down notification for [shift] if it has a meaningful end
  /// time (i.e. not an off-day) and the wind-down window is still in the future.
  void _scheduleWindDown(Shift shift) {
    if (shift.type == ShiftType.off) return;
    final sleepTime = shift.endTime;
    final windDownTime = sleepTime.subtract(const Duration(minutes: 60));
    if (windDownTime.isBefore(DateTime.now())) return;
    _alarmService.scheduleWindDownNotification(sleepTime);
  }
}
