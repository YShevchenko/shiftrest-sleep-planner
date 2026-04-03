import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/sleep_block.dart';
import '../../core/constants.dart';

/// Shift-aware alarm service.
/// Sets alarms that account for sleep cycles to wake during light sleep.
class AlarmService {
  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  AlarmService() : _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  /// Calculate the best wake time based on sleep cycles.
  /// Wakes during light sleep (end of a 90-min cycle) within [windowMinutes]
  /// before the target wake time.
  DateTime calculateSmartWakeTime({
    required DateTime sleepStart,
    required DateTime targetWakeTime,
    int windowMinutes = 30,
  }) {
    final cycleDuration = const Duration(minutes: AppConstants.sleepCycleMinutes);
    final totalSleepDuration = targetWakeTime.difference(sleepStart);

    if (totalSleepDuration.isNegative || totalSleepDuration.inMinutes < 60) {
      return targetWakeTime;
    }

    // Calculate number of complete sleep cycles
    final completeCycles = totalSleepDuration.inMinutes ~/ AppConstants.sleepCycleMinutes;

    if (completeCycles == 0) return targetWakeTime;

    // End of the last complete cycle before target
    final lastCycleEnd = sleepStart.add(cycleDuration * completeCycles);

    // If last cycle end is within the window, use it
    final diff = targetWakeTime.difference(lastCycleEnd).inMinutes;
    if (diff >= 0 && diff <= windowMinutes) {
      return lastCycleEnd;
    }

    // Otherwise use the target time
    return targetWakeTime;
  }

  /// Schedule an alarm notification.
  Future<void> scheduleAlarm({
    required int id,
    required DateTime wakeTime,
    required String title,
    String? body,
  }) async {
    await initialize();

    // For simplicity, use a basic notification schedule
    // In production, you'd use exact alarm scheduling
    final androidDetails = AndroidNotificationDetails(
      'shiftrest_alarm',
      'ShiftRest Alarms',
      channelDescription: 'Alarm notifications for ShiftRest',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body ?? 'Time to wake up!',
      details,
    );
  }

  /// Cancel a scheduled alarm.
  Future<void> cancelAlarm(int id) async {
    await initialize();
    await _notifications.cancel(id);
  }

  /// Cancel all alarms.
  Future<void> cancelAllAlarms() async {
    await initialize();
    await _notifications.cancelAll();
  }

  /// Schedule a wind-down notification 60 minutes before [sleepTime].
  /// Notification ID 9001 is reserved for the wind-down reminder.
  Future<void> scheduleWindDownNotification(DateTime sleepTime) async {
    await initialize();

    final windDownTime = sleepTime.subtract(const Duration(minutes: 60));
    final now = DateTime.now();

    // Don't schedule if wind-down time is already in the past
    if (windDownTime.isBefore(now)) return;

    final androidDetails = AndroidNotificationDetails(
      'shiftrest_winddown',
      'ShiftRest Wind-Down',
      channelDescription: 'Wind-down reminders before sleep',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzWindDown = tz.TZDateTime.from(windDownTime, tz.local);

    await _notifications.zonedSchedule(
      9001,
      'Time to wind down',
      'Sleep in 60 minutes — start your wind-down routine.',
      tzWindDown,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel the wind-down notification.
  Future<void> cancelWindDownNotification() async {
    await initialize();
    await _notifications.cancel(9001);
  }

  /// Schedule alarm for a sleep block.
  Future<void> scheduleAlarmForBlock(SleepBlock block) async {
    final smartWake = calculateSmartWakeTime(
      sleepStart: block.startTime,
      targetWakeTime: block.endTime,
    );

    await scheduleAlarm(
      id: block.hashCode,
      wakeTime: smartWake,
      title: block.type == SleepBlockType.nap ? 'Nap Over' : 'Time to Wake Up',
      body: block.type == SleepBlockType.nap
          ? 'Your power nap is complete. Time to get moving!'
          : 'Rise and shine! You slept for ${block.durationHours.toStringAsFixed(1)}h.',
    );
  }
}
