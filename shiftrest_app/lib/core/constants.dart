/// App-wide constants for ShiftRest.
class AppConstants {
  AppConstants._();

  static const String appName = 'ShiftRest';
  static const String appTagline = 'We do the sleep math for your shifts';

  // Sleep algorithm thresholds (hours)
  static const double longWindowThreshold = 7.0;
  static const double mediumWindowThreshold = 4.0;

  // Default commute time in minutes
  static const int defaultCommuteMinutes = 30;

  // Default prep time in minutes (getting ready before shift)
  static const int defaultPrepMinutes = 30;

  // Nap durations in minutes
  static const List<int> napDurations = [10, 20, 26, 90];

  // Sleep cycle duration in minutes
  static const int sleepCycleMinutes = 90;

  // Circadian peak sleepiness window
  static const int circadianPeakStartHour = 1; // 1 AM
  static const int circadianPeakEndHour = 5; // 5 AM

  // Night shift recommended sleep window
  static const int nightShiftSleepStartHour = 7; // 7 AM
  static const int nightShiftSleepEndHour = 15; // 3 PM

  // Database
  static const String databaseName = 'shiftrest.db';
  static const int databaseVersion = 2;

  // Shift types
  static const String shiftTypeDay = 'day';
  static const String shiftTypeEvening = 'evening';
  static const String shiftTypeNight = 'night';
  static const String shiftTypeOff = 'off';

  // Noise types
  static const String noiseWhite = 'white';
  static const String noiseBrown = 'brown';
  static const String noisePink = 'pink';

  // Schedule view days
  static const int scheduleViewDays = 14;
}
