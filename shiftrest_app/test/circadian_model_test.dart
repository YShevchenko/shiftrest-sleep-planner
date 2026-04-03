import 'package:flutter_test/flutter_test.dart';
import 'package:shiftrest_app/domain/services/circadian_model.dart';

void main() {
  group('CircadianModel', () {
    test('alertness at 3 AM is very low', () {
      final alertness = CircadianModel.alertnessAtHour(3.0);
      expect(alertness, lessThan(0.3));
    });

    test('alertness at 10 AM is high', () {
      final alertness = CircadianModel.alertnessAtHour(10.0);
      expect(alertness, greaterThanOrEqualTo(0.5));
    });

    test('alertness at 2-3 PM dips (post-prandial)', () {
      final alertness14 = CircadianModel.alertnessAtHour(14.0);
      final alertness16 = CircadianModel.alertnessAtHour(16.0);
      // Afternoon dip (14h) should be lower than the peak (16h)
      // because the post-prandial dip reduces the circadian value
      expect(alertness14, lessThan(alertness16));
    });

    test('alertness at 8 PM is relatively high', () {
      final alertness = CircadianModel.alertnessAtHour(20.0);
      expect(alertness, greaterThan(0.4));
    });

    test('alertness values are between 0 and 1', () {
      for (double h = 0; h < 24; h += 0.5) {
        final alertness = CircadianModel.alertnessAtHour(h);
        expect(alertness, greaterThanOrEqualTo(0.0));
        expect(alertness, lessThanOrEqualTo(1.0));
      }
    });

    test('generates 48 data points for 24-hour curve', () {
      final curve = CircadianModel.generate24HourCurve();
      expect(curve.length, 48);
    });

    test('optimal nap hour is in the afternoon', () {
      final napHour = CircadianModel.optimalNapHour();
      expect(napHour, greaterThanOrEqualTo(13.0));
      expect(napHour, lessThanOrEqualTo(16.0));
    });

    test('sleep quality is higher during circadian trough', () {
      // Sleep from 1-5 AM (deep sleep window) should be higher quality
      final nightQuality = CircadianModel.sleepQualityFactor(1.0, 5.0);
      // Sleep from 10 AM - 2 PM (peak alertness) should be lower quality
      final dayQuality = CircadianModel.sleepQualityFactor(10.0, 14.0);

      expect(nightQuality, greaterThan(dayQuality));
    });

    test('phase descriptions are correct for key hours', () {
      expect(CircadianModel.phaseDescription(3.0), 'Deep Sleep Window');
      expect(CircadianModel.phaseDescription(10.0), 'Peak Performance');
      expect(CircadianModel.phaseDescription(14.5), 'Afternoon Dip');
      expect(CircadianModel.phaseDescription(19.0), 'Evening Peak');
      expect(CircadianModel.phaseDescription(22.0), 'Sleep Onset Zone');
    });
  });
}
