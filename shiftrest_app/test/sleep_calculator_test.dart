import 'package:flutter_test/flutter_test.dart';
import 'package:shiftrest_app/domain/models/shift.dart';
import 'package:shiftrest_app/domain/models/sleep_plan.dart';
import 'package:shiftrest_app/domain/models/sleep_block.dart';
import 'package:shiftrest_app/domain/services/sleep_calculator.dart';

void main() {
  const calculator = SleepCalculator(commuteMinutes: 30, prepMinutes: 30);

  group('SleepCalculator', () {
    group('Single block plan (>= 7h window)', () {
      test('returns single block strategy for long gap between shifts', () {
        // Night shift ending at 7 AM, next shift at 10 PM = 15h gap
        final currentShift = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 22, 0),
          endTime: DateTime(2026, 4, 1, 7, 0), // overnight
          type: ShiftType.night,
          commuteMinutes: 30,
        );
        final nextShift = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 22, 0),
          endTime: DateTime(2026, 4, 2, 7, 0),
          type: ShiftType.night,
          commuteMinutes: 30,
        );

        final plan = calculator.calculateSleepPlan(
          currentShift: currentShift,
          nextShift: nextShift,
          date: DateTime(2026, 4, 2),
        );

        expect(plan.strategy, SleepStrategy.singleBlock);
        expect(plan.sleepBlocks.length, 1);
        expect(plan.sleepBlocks.first.type, SleepBlockType.core);
        expect(plan.totalPlannedHours, greaterThanOrEqualTo(6.0));
      });

      test('plans 7-8h sleep block for generous window', () {
        final currentShift = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 8, 0),
          endTime: DateTime(2026, 4, 1, 16, 0),
          type: ShiftType.day,
          commuteMinutes: 30,
        );
        final nextShift = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 8, 0),
          endTime: DateTime(2026, 4, 2, 16, 0),
          type: ShiftType.day,
          commuteMinutes: 30,
        );

        final plan = calculator.calculateSleepPlan(
          currentShift: currentShift,
          nextShift: nextShift,
          date: DateTime(2026, 4, 2),
        );

        expect(plan.strategy, SleepStrategy.singleBlock);
        final hours = plan.totalPlannedHours;
        expect(hours, greaterThanOrEqualTo(6.0));
        expect(hours, lessThanOrEqualTo(9.0));
      });
    });

    group('Core with nap plan (4-7h window)', () {
      test('returns core + nap for medium gap', () {
        // Shift ending at 7 AM, next shift starting at 2 PM = 7h gap
        // After commute (30min) and prep (30min), that's 6h available
        final currentShift = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 22, 0),
          endTime: DateTime(2026, 4, 1, 7, 0),
          type: ShiftType.night,
          commuteMinutes: 30,
        );
        final nextShift = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 14, 0),
          endTime: DateTime(2026, 4, 2, 22, 0),
          type: ShiftType.evening,
          commuteMinutes: 30,
        );

        final plan = calculator.calculateSleepPlan(
          currentShift: currentShift,
          nextShift: nextShift,
          date: DateTime(2026, 4, 2),
        );

        expect(plan.strategy, SleepStrategy.coreWithNap);
        expect(plan.sleepBlocks.length, 2);
        expect(plan.coreBlocks.length, 1);
        expect(plan.napBlocks.length, 1);

        // Nap should be 20 minutes
        final nap = plan.napBlocks.first;
        expect(nap.duration.inMinutes, 20);
      });
    });

    group('Split sleep plan (< 4h window)', () {
      test('returns split sleep for very tight turnaround', () {
        // Shift ending at 7 AM, next shift starting at 10 AM = 3h gap
        // After commute: available from 7:30 to 9:00 = 1.5h
        final currentShift = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 22, 0),
          endTime: DateTime(2026, 4, 1, 7, 0),
          type: ShiftType.night,
          commuteMinutes: 30,
        );
        final nextShift = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 10, 0),
          endTime: DateTime(2026, 4, 2, 18, 0),
          type: ShiftType.day,
          commuteMinutes: 30,
        );

        final plan = calculator.calculateSleepPlan(
          currentShift: currentShift,
          nextShift: nextShift,
          date: DateTime(2026, 4, 2),
        );

        expect(plan.strategy, SleepStrategy.splitSleep);
        expect(plan.sleepBlocks.isNotEmpty, true);
      });
    });

    group('Off day plan', () {
      test('returns off day strategy for off shifts', () {
        final offShift = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 0, 0),
          endTime: DateTime(2026, 4, 2, 0, 0),
          type: ShiftType.off,
        );

        final plan = calculator.calculateSleepPlan(
          nextShift: offShift,
          date: DateTime(2026, 4, 2),
        );

        expect(plan.strategy, SleepStrategy.offDay);
        expect(plan.sleepBlocks.isNotEmpty, true);
      });

      test('recommends recovery for high sleep debt on off day', () {
        final offShift = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 0, 0),
          endTime: DateTime(2026, 4, 2, 0, 0),
          type: ShiftType.off,
        );

        final plan = calculator.calculateSleepPlan(
          nextShift: offShift,
          date: DateTime(2026, 4, 2),
          sleepDebt: 5.0,
        );

        expect(plan.recommendation, contains('sleep debt'));
        expect(plan.sleepDebtHours, 5.0);
      });
    });

    group('Schedule-wide calculation', () {
      test('calculates plans for multiple consecutive shifts', () {
        final shifts = [
          Shift(
            date: DateTime(2026, 4, 1),
            startTime: DateTime(2026, 4, 1, 22, 0),
            endTime: DateTime(2026, 4, 1, 7, 0),
            type: ShiftType.night,
          ),
          Shift(
            date: DateTime(2026, 4, 2),
            startTime: DateTime(2026, 4, 2, 22, 0),
            endTime: DateTime(2026, 4, 2, 7, 0),
            type: ShiftType.night,
          ),
          Shift(
            date: DateTime(2026, 4, 3),
            startTime: DateTime(2026, 4, 3, 0, 0),
            endTime: DateTime(2026, 4, 3, 0, 0),
            type: ShiftType.off,
          ),
        ];

        final plans = calculator.calculatePlansForSchedule(shifts);

        expect(plans.length, 3);
        expect(plans[2].strategy, SleepStrategy.offDay);
      });

      test('tracks cumulative sleep debt', () {
        final shifts = [
          Shift(
            date: DateTime(2026, 4, 1),
            startTime: DateTime(2026, 4, 1, 22, 0),
            endTime: DateTime(2026, 4, 1, 7, 0),
            type: ShiftType.night,
          ),
          Shift(
            date: DateTime(2026, 4, 2),
            startTime: DateTime(2026, 4, 2, 22, 0),
            endTime: DateTime(2026, 4, 2, 7, 0),
            type: ShiftType.night,
          ),
        ];

        final plans = calculator.calculatePlansForSchedule(shifts);

        // Second plan should have some sleep debt from first
        expect(plans[1].sleepDebtHours, isNotNull);
      });
    });

    group('Shift overlap detection', () {
      test('detects overlapping shifts', () {
        final a = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 8, 0),
          endTime: DateTime(2026, 4, 1, 16, 0),
          type: ShiftType.day,
        );
        final b = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 14, 0),
          endTime: DateTime(2026, 4, 1, 22, 0),
          type: ShiftType.evening,
        );

        expect(SleepCalculator.shiftsOverlap(a, b), true);
      });

      test('non-overlapping shifts return false', () {
        final a = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 8, 0),
          endTime: DateTime(2026, 4, 1, 16, 0),
          type: ShiftType.day,
        );
        final b = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 22, 0),
          endTime: DateTime(2026, 4, 1, 6, 0),
          type: ShiftType.night,
        );

        expect(SleepCalculator.shiftsOverlap(a, b), false);
      });

      test('detects overnight shift overlap', () {
        final a = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 22, 0),
          endTime: DateTime(2026, 4, 1, 6, 0), // overnight
          type: ShiftType.night,
        );
        final b = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 4, 0),
          endTime: DateTime(2026, 4, 2, 12, 0),
          type: ShiftType.day,
        );

        expect(SleepCalculator.shiftsOverlap(a, b), true);
      });
    });

    group('Gap calculation', () {
      test('calculates gap between consecutive shifts', () {
        final ending = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 8, 0),
          endTime: DateTime(2026, 4, 1, 16, 0),
          type: ShiftType.day,
        );
        final starting = Shift(
          date: DateTime(2026, 4, 2),
          startTime: DateTime(2026, 4, 2, 8, 0),
          endTime: DateTime(2026, 4, 2, 16, 0),
          type: ShiftType.day,
        );

        final gap = SleepCalculator.gapBetweenShifts(ending, starting);
        expect(gap, 16.0); // 16h gap from 4PM to 8AM next day
      });
    });
  });
}
