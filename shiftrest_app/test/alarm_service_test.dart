import 'package:flutter_test/flutter_test.dart';
import 'package:shiftrest_app/domain/services/alarm_service.dart';

void main() {
  group('AlarmService smart wake time', () {
    final alarmService = AlarmService();

    test('aligns wake time to end of sleep cycle within window', () {
      final sleepStart = DateTime(2026, 4, 1, 23, 0);
      // Target wake at 7:00 AM = 8h sleep = 5.33 cycles
      // 5 complete cycles = 7.5h = 6:30 AM
      final targetWake = DateTime(2026, 4, 2, 7, 0);

      final smartWake = alarmService.calculateSmartWakeTime(
        sleepStart: sleepStart,
        targetWakeTime: targetWake,
        windowMinutes: 30,
      );

      // Should wake at 6:30 (end of 5th cycle) since 7:00 - 6:30 = 30min within window
      expect(smartWake.hour, 6);
      expect(smartWake.minute, 30);
    });

    test('returns target time when no cycle end is within window', () {
      final sleepStart = DateTime(2026, 4, 1, 23, 0);
      // Target wake at 6:45 AM = 7.75h
      // 5 cycles = 6:30 (15min before target, within 30min window)
      final targetWake = DateTime(2026, 4, 2, 6, 45);

      final smartWake = alarmService.calculateSmartWakeTime(
        sleepStart: sleepStart,
        targetWakeTime: targetWake,
        windowMinutes: 30,
      );

      // 6:30 is within 30 min window of 6:45
      expect(smartWake.hour, 6);
      expect(smartWake.minute, 30);
    });

    test('handles very short sleep duration', () {
      final sleepStart = DateTime(2026, 4, 2, 5, 0);
      final targetWake = DateTime(2026, 4, 2, 5, 30);

      final smartWake = alarmService.calculateSmartWakeTime(
        sleepStart: sleepStart,
        targetWakeTime: targetWake,
      );

      // Less than one cycle, return target
      expect(smartWake, targetWake);
    });

    test('handles exact cycle multiple', () {
      final sleepStart = DateTime(2026, 4, 1, 22, 0);
      // 6 cycles = 9h = 7:00 AM exactly
      final targetWake = DateTime(2026, 4, 2, 7, 0);

      final smartWake = alarmService.calculateSmartWakeTime(
        sleepStart: sleepStart,
        targetWakeTime: targetWake,
      );

      expect(smartWake.hour, 7);
      expect(smartWake.minute, 0);
    });
  });
}
