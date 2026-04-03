import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class HealthService {
  static final _health = Health();
  static const _types = [HealthDataType.SLEEP_SESSION];
  static const _permissions = [HealthDataAccess.READ_WRITE];

  static Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      return await _health.requestAuthorization(_types, permissions: _permissions);
    } catch (e) {
      debugPrint('Health permission error: $e');
      return false;
    }
  }

  static Future<bool> writeSleepSession({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      return await _health.writeHealthData(
        value: 0,
        type: HealthDataType.SLEEP_SESSION,
        startTime: start,
        endTime: end,
      );
    } catch (e) {
      debugPrint('Health write error: $e');
      return false;
    }
  }
}
