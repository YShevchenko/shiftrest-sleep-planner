import 'dart:math';

/// Models the human circadian alertness curve.
/// Based on the two-process model of sleep regulation (Borbely).
class CircadianModel {
  /// Get alertness level (0.0 - 1.0) for a given hour of the day.
  /// 0.0 = lowest alertness (deepest sleep drive)
  /// 1.0 = peak alertness
  static double alertnessAtHour(double hour) {
    // Normalize to 0-24
    final h = hour % 24;

    // Circadian process (Process C) - roughly sinusoidal
    // Peak alertness around 10 AM and 8 PM
    // Trough around 3-4 AM and slight dip around 2-3 PM
    final circadian = 0.5 + 0.5 * cos(2 * pi * (h - 16) / 24);

    // Afternoon dip (post-prandial)
    final afternoonDip = h >= 13 && h <= 15
        ? 0.15 * sin(pi * (h - 13) / 2)
        : 0.0;

    // Deep night trough enhancement
    final nightDip = h >= 1 && h <= 5
        ? 0.2 * sin(pi * (h - 1) / 4)
        : 0.0;

    return (circadian - afternoonDip - nightDip).clamp(0.0, 1.0);
  }

  /// Generate alertness data for a full 24-hour period.
  /// Returns list of (hour, alertness) pairs at 30-minute intervals.
  static List<AlertnessPoint> generate24HourCurve() {
    final points = <AlertnessPoint>[];
    for (double h = 0; h < 24; h += 0.5) {
      points.add(AlertnessPoint(hour: h, alertness: alertnessAtHour(h)));
    }
    return points;
  }

  /// Get the optimal nap window based on circadian phase.
  /// Returns the hour (0-24) when a nap would be most beneficial.
  static double optimalNapHour() {
    // The post-prandial dip (2-3 PM) is the natural nap window
    return 14.0;
  }

  /// Rate sleep quality based on when the sleep occurs.
  /// Sleep during high-sleep-drive hours (1-5 AM) is most restorative.
  static double sleepQualityFactor(double startHour, double endHour) {
    double quality = 0.0;
    double h = startHour;
    int steps = 0;
    while (h != endHour && steps < 48) {
      // Inverse of alertness = sleep drive
      quality += (1.0 - alertnessAtHour(h));
      h = (h + 0.5) % 24;
      steps++;
    }
    if (steps == 0) return 0.5;
    return (quality / steps).clamp(0.0, 1.0);
  }

  /// Get a human-readable description of the circadian phase.
  static String phaseDescription(double hour) {
    final h = hour % 24;
    if (h >= 1 && h < 5) return 'Deep Sleep Window';
    if (h >= 5 && h < 7) return 'Wake-Up Zone';
    if (h >= 7 && h < 10) return 'Morning Ramp-Up';
    if (h >= 10 && h < 12) return 'Peak Performance';
    if (h >= 12 && h < 14) return 'Post-Lunch';
    if (h >= 14 && h < 16) return 'Afternoon Dip';
    if (h >= 16 && h < 18) return 'Second Wind';
    if (h >= 18 && h < 20) return 'Evening Peak';
    if (h >= 20 && h < 22) return 'Wind Down';
    return 'Sleep Onset Zone';
  }
}

/// A data point on the circadian alertness curve.
class AlertnessPoint {
  final double hour;
  final double alertness;

  const AlertnessPoint({required this.hour, required this.alertness});
}
