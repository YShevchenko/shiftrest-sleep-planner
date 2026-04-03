import 'package:flutter_test/flutter_test.dart';
import 'package:shiftrest_app/domain/models/shift.dart';
import 'package:shiftrest_app/domain/models/sleep_block.dart';
import 'package:shiftrest_app/domain/models/sleep_plan.dart';

void main() {
  group('Shift serialization', () {
    test('toMap and fromMap roundtrip', () {
      final shift = Shift(
        id: 'test-shift-1',
        date: DateTime(2026, 4, 1),
        startTime: DateTime(2026, 4, 1, 22, 0),
        endTime: DateTime(2026, 4, 2, 7, 0),
        type: ShiftType.night,
        commuteMinutes: 45,
        notes: 'Test shift',
      );

      final map = shift.toMap();
      final restored = Shift.fromMap(map);

      expect(restored.id, shift.id);
      expect(restored.date, shift.date);
      expect(restored.startTime, shift.startTime);
      expect(restored.endTime, shift.endTime);
      expect(restored.type, ShiftType.night);
      expect(restored.commuteMinutes, 45);
      expect(restored.notes, 'Test shift');
    });

    test('preserves all shift types', () {
      for (final type in ShiftType.values) {
        final shift = Shift(
          date: DateTime(2026, 4, 1),
          startTime: DateTime(2026, 4, 1, 8, 0),
          endTime: DateTime(2026, 4, 1, 16, 0),
          type: type,
        );

        final restored = Shift.fromMap(shift.toMap());
        expect(restored.type, type);
      }
    });

    test('duration calculation for normal shift', () {
      final shift = Shift(
        date: DateTime(2026, 4, 1),
        startTime: DateTime(2026, 4, 1, 8, 0),
        endTime: DateTime(2026, 4, 1, 16, 0),
        type: ShiftType.day,
      );

      expect(shift.duration.inHours, 8);
      expect(shift.isOvernight, false);
    });

    test('duration calculation for overnight shift', () {
      final shift = Shift(
        date: DateTime(2026, 4, 1),
        startTime: DateTime(2026, 4, 1, 22, 0),
        endTime: DateTime(2026, 4, 1, 6, 0), // end time is "before" start
        type: ShiftType.night,
      );

      expect(shift.isOvernight, true);
      expect(shift.duration.inHours, 8);
    });
  });

  group('SleepBlock serialization', () {
    test('toMap and fromMap roundtrip', () {
      final block = SleepBlock(
        id: 'test-block-1',
        startTime: DateTime(2026, 4, 1, 23, 0),
        endTime: DateTime(2026, 4, 2, 7, 0),
        type: SleepBlockType.core,
        isPlanned: true,
        qualityRating: 4,
      );

      final map = block.toMap();
      final restored = SleepBlock.fromMap(map);

      expect(restored.id, block.id);
      expect(restored.startTime, block.startTime);
      expect(restored.endTime, block.endTime);
      expect(restored.type, SleepBlockType.core);
      expect(restored.isPlanned, true);
      expect(restored.qualityRating, 4);
      expect(restored.tags, isEmpty);
    });

    test('tags roundtrip with multiple values', () {
      final block = SleepBlock(
        startTime: DateTime(2026, 4, 1, 23, 0),
        endTime: DateTime(2026, 4, 2, 7, 0),
        type: SleepBlockType.core,
        tags: ['Noisy', 'Caffeine', 'Stress'],
      );

      final restored = SleepBlock.fromMap(block.toMap());
      expect(restored.tags, containsAll(['Noisy', 'Caffeine', 'Stress']));
      expect(restored.tags.length, 3);
    });

    test('tags roundtrip with empty list', () {
      final block = SleepBlock(
        startTime: DateTime(2026, 4, 1, 23, 0),
        endTime: DateTime(2026, 4, 2, 7, 0),
        type: SleepBlockType.core,
      );

      final restored = SleepBlock.fromMap(block.toMap());
      expect(restored.tags, isEmpty);
    });

    test('duration calculation', () {
      final block = SleepBlock(
        startTime: DateTime(2026, 4, 1, 23, 0),
        endTime: DateTime(2026, 4, 2, 7, 0),
        type: SleepBlockType.core,
      );

      expect(block.duration.inHours, 8);
      expect(block.durationHours, 8.0);
    });

    test('nap block serialization', () {
      final nap = SleepBlock(
        startTime: DateTime(2026, 4, 1, 14, 0),
        endTime: DateTime(2026, 4, 1, 14, 20),
        type: SleepBlockType.nap,
        isPlanned: true,
      );

      final restored = SleepBlock.fromMap(nap.toMap());
      expect(restored.type, SleepBlockType.nap);
      expect(restored.duration.inMinutes, 20);
    });
  });

  group('SleepPlan serialization', () {
    test('toMap and fromMap roundtrip', () {
      final blocks = [
        SleepBlock(
          id: 'block-1',
          startTime: DateTime(2026, 4, 1, 23, 0),
          endTime: DateTime(2026, 4, 2, 6, 30),
          type: SleepBlockType.core,
        ),
        SleepBlock(
          id: 'block-2',
          startTime: DateTime(2026, 4, 2, 12, 0),
          endTime: DateTime(2026, 4, 2, 12, 20),
          type: SleepBlockType.nap,
        ),
      ];

      final plan = SleepPlan(
        id: 'plan-1',
        date: DateTime(2026, 4, 2),
        shiftId: 'shift-1',
        sleepBlocks: blocks,
        strategy: SleepStrategy.coreWithNap,
        sleepDebtHours: 1.5,
        recommendation: 'Test recommendation',
      );

      final map = plan.toMap();
      final restored = SleepPlan.fromMap(map, blocks);

      expect(restored.id, plan.id);
      expect(restored.date, plan.date);
      expect(restored.shiftId, 'shift-1');
      expect(restored.strategy, SleepStrategy.coreWithNap);
      expect(restored.sleepDebtHours, 1.5);
      expect(restored.recommendation, 'Test recommendation');
      expect(restored.sleepBlocks.length, 2);
    });

    test('total planned hours calculation', () {
      final plan = SleepPlan(
        date: DateTime(2026, 4, 2),
        sleepBlocks: [
          SleepBlock(
            startTime: DateTime(2026, 4, 1, 23, 0),
            endTime: DateTime(2026, 4, 2, 6, 0),
            type: SleepBlockType.core,
          ),
          SleepBlock(
            startTime: DateTime(2026, 4, 2, 12, 0),
            endTime: DateTime(2026, 4, 2, 12, 20),
            type: SleepBlockType.nap,
          ),
        ],
        strategy: SleepStrategy.coreWithNap,
      );

      // 7h core + 20min nap = 7.33h
      expect(plan.totalPlannedHours, closeTo(7.33, 0.1));
    });

    test('preserves all strategy types', () {
      for (final strategy in SleepStrategy.values) {
        final plan = SleepPlan(
          date: DateTime(2026, 4, 1),
          sleepBlocks: [],
          strategy: strategy,
        );

        final restored = SleepPlan.fromMap(plan.toMap(), []);
        expect(restored.strategy, strategy);
      }
    });
  });
}
