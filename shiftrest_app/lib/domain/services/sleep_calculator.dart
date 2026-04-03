import '../models/shift.dart';
import '../models/sleep_block.dart';
import '../models/sleep_plan.dart';
import '../../core/constants.dart';

/// Core sleep calculation engine.
/// Computes optimal sleep windows from shift schedules.
class SleepCalculator {
  /// Default commute + prep overhead in minutes.
  final int commuteMinutes;
  final int prepMinutes;

  const SleepCalculator({
    this.commuteMinutes = AppConstants.defaultCommuteMinutes,
    this.prepMinutes = AppConstants.defaultPrepMinutes,
  });

  /// Calculate optimal sleep plan between two consecutive shifts.
  /// [currentShift] is the shift that just ended (or null if first day).
  /// [nextShift] is the upcoming shift.
  SleepPlan calculateSleepPlan({
    Shift? currentShift,
    required Shift nextShift,
    required DateTime date,
    double sleepDebt = 0.0,
  }) {
    if (nextShift.type == ShiftType.off) {
      return _offDayPlan(date, currentShift, sleepDebt);
    }

    if (currentShift == null) {
      return _firstDayPlan(nextShift, date, sleepDebt);
    }

    // Calculate the available window between end of current shift and start of next
    final DateTime availableStart = _getAvailableStart(currentShift);
    final DateTime availableEnd = _getAvailableEnd(nextShift);

    final double windowHours = _calculateWindowHours(availableStart, availableEnd);

    if (windowHours >= AppConstants.longWindowThreshold) {
      return _singleBlockPlan(
        date: date,
        shiftId: nextShift.id,
        availableStart: availableStart,
        availableEnd: availableEnd,
        windowHours: windowHours,
        nextShift: nextShift,
        sleepDebt: sleepDebt,
      );
    } else if (windowHours >= AppConstants.mediumWindowThreshold) {
      return _coreWithNapPlan(
        date: date,
        shiftId: nextShift.id,
        availableStart: availableStart,
        availableEnd: availableEnd,
        windowHours: windowHours,
        nextShift: nextShift,
        sleepDebt: sleepDebt,
      );
    } else {
      return _splitSleepPlan(
        date: date,
        shiftId: nextShift.id,
        availableStart: availableStart,
        availableEnd: availableEnd,
        windowHours: windowHours,
        nextShift: nextShift,
        sleepDebt: sleepDebt,
      );
    }
  }

  /// Calculate plans for a list of shifts across multiple days.
  List<SleepPlan> calculatePlansForSchedule(List<Shift> shifts) {
    if (shifts.isEmpty) return [];

    // Sort shifts by start time
    final sorted = List<Shift>.from(shifts)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final plans = <SleepPlan>[];
    double cumulativeDebt = 0.0;

    for (int i = 0; i < sorted.length; i++) {
      final currentShift = i > 0 ? sorted[i - 1] : null;
      final nextShift = sorted[i];

      final plan = calculateSleepPlan(
        currentShift: currentShift,
        nextShift: nextShift,
        date: nextShift.date,
        sleepDebt: cumulativeDebt,
      );

      plans.add(plan);

      // Track sleep debt: target 8h, actual is planned
      final planned = plan.totalPlannedHours;
      cumulativeDebt += (8.0 - planned).clamp(0.0, 8.0);
      // Recovery during off days
      if (nextShift.type == ShiftType.off) {
        cumulativeDebt = (cumulativeDebt - 2.0).clamp(0.0, double.infinity);
      }
    }

    return plans;
  }

  // -- Private helpers --

  DateTime _getAvailableStart(Shift shift) {
    final shiftEnd = shift.isOvernight
        ? shift.endTime.add(const Duration(days: 1))
        : shift.endTime;
    return shiftEnd.add(Duration(minutes: shift.commuteMinutes));
  }

  DateTime _getAvailableEnd(Shift nextShift) {
    return nextShift.startTime.subtract(
      Duration(minutes: nextShift.commuteMinutes + prepMinutes),
    );
  }

  double _calculateWindowHours(DateTime start, DateTime end) {
    var diff = end.difference(start);
    if (diff.isNegative) {
      // Next shift is next day
      diff = end.add(const Duration(days: 1)).difference(start);
    }
    return diff.inMinutes / 60.0;
  }

  /// Adjust sleep start to favor circadian peak (1-5 AM).
  DateTime _adjustForCircadian(DateTime sleepStart, double durationHours) {
    final hour = sleepStart.hour;
    // If sleep start is near the circadian window, keep it
    if (hour >= 22 || hour <= 2) return sleepStart;
    // For morning sleepers (post-night-shift), try to start by 7 AM
    if (hour >= 5 && hour <= 9) return sleepStart;
    return sleepStart;
  }

  SleepPlan _singleBlockPlan({
    required DateTime date,
    required String shiftId,
    required DateTime availableStart,
    required DateTime availableEnd,
    required double windowHours,
    required Shift nextShift,
    required double sleepDebt,
  }) {
    // Aim for 7-8 hours, centered in the available window
    final targetHours = windowHours.clamp(7.0, 8.5);
    final targetMinutes = (targetHours * 60).round();

    // Round to nearest sleep cycle
    final cycles = (targetMinutes / AppConstants.sleepCycleMinutes).round();
    final adjustedMinutes = cycles * AppConstants.sleepCycleMinutes;

    var sleepStart = availableStart.add(const Duration(minutes: 15)); // 15min wind-down
    sleepStart = _adjustForCircadian(sleepStart, adjustedMinutes / 60.0);
    final sleepEnd = sleepStart.add(Duration(minutes: adjustedMinutes));

    // Make sure we don't overflow the window
    final actualEnd = sleepEnd.isAfter(availableEnd) ? availableEnd : sleepEnd;

    return SleepPlan(
      date: date,
      shiftId: shiftId,
      sleepBlocks: [
        SleepBlock(
          startTime: sleepStart,
          endTime: actualEnd,
          type: SleepBlockType.core,
        ),
      ],
      strategy: SleepStrategy.singleBlock,
      sleepDebtHours: sleepDebt,
      recommendation: _buildRecommendation(
        nextShift.type,
        SleepStrategy.singleBlock,
        actualEnd.difference(sleepStart).inMinutes / 60.0,
      ),
    );
  }

  SleepPlan _coreWithNapPlan({
    required DateTime date,
    required String shiftId,
    required DateTime availableStart,
    required DateTime availableEnd,
    required double windowHours,
    required Shift nextShift,
    required double sleepDebt,
  }) {
    // Core sleep: available window minus 1 hour (for nap + buffer)
    final coreMinutes = ((windowHours - 1.0) * 60).round();
    // Round down to nearest sleep cycle
    final cycles = (coreMinutes / AppConstants.sleepCycleMinutes).floor();
    final adjustedCoreMinutes = (cycles * AppConstants.sleepCycleMinutes).clamp(
      AppConstants.sleepCycleMinutes,
      coreMinutes,
    );

    final coreStart = availableStart.add(const Duration(minutes: 10));
    final coreEnd = coreStart.add(Duration(minutes: adjustedCoreMinutes));

    // 20-min nap about 90 min before shift prep
    final napEnd = availableEnd;
    final napStart = napEnd.subtract(const Duration(minutes: 20));

    return SleepPlan(
      date: date,
      shiftId: shiftId,
      sleepBlocks: [
        SleepBlock(
          startTime: coreStart,
          endTime: coreEnd.isAfter(napStart) ? napStart.subtract(const Duration(minutes: 30)) : coreEnd,
          type: SleepBlockType.core,
        ),
        SleepBlock(
          startTime: napStart,
          endTime: napEnd,
          type: SleepBlockType.nap,
        ),
      ],
      strategy: SleepStrategy.coreWithNap,
      sleepDebtHours: sleepDebt,
      recommendation: _buildRecommendation(
        nextShift.type,
        SleepStrategy.coreWithNap,
        windowHours,
      ),
    );
  }

  SleepPlan _splitSleepPlan({
    required DateTime date,
    required String shiftId,
    required DateTime availableStart,
    required DateTime availableEnd,
    required double windowHours,
    required Shift nextShift,
    required double sleepDebt,
  }) {
    // Very tight: split into 2-3h block + 90min nap
    final totalMinutes = (windowHours * 60).round();

    // First block: 2/3 of available time
    final firstBlockMinutes = (totalMinutes * 2 / 3).round().clamp(60, 180);
    final firstStart = availableStart.add(const Duration(minutes: 5));
    final firstEnd = firstStart.add(Duration(minutes: firstBlockMinutes));

    // Second block: remaining time minus 30min buffer
    final remainingMinutes = totalMinutes - firstBlockMinutes - 30;
    final secondBlockMinutes = remainingMinutes.clamp(20, 90);
    final secondEnd = availableEnd;
    final secondStart = secondEnd.subtract(Duration(minutes: secondBlockMinutes));

    return SleepPlan(
      date: date,
      shiftId: shiftId,
      sleepBlocks: [
        SleepBlock(
          startTime: firstStart,
          endTime: firstEnd,
          type: SleepBlockType.core,
        ),
        if (secondBlockMinutes >= 20)
          SleepBlock(
            startTime: secondStart,
            endTime: secondEnd,
            type: SleepBlockType.nap,
          ),
      ],
      strategy: SleepStrategy.splitSleep,
      sleepDebtHours: sleepDebt,
      recommendation: _buildRecommendation(
        nextShift.type,
        SleepStrategy.splitSleep,
        windowHours,
      ),
    );
  }

  SleepPlan _offDayPlan(DateTime date, Shift? previousShift, double sleepDebt) {
    // Off day: recommend a generous recovery sleep
    final now = DateTime(date.year, date.month, date.day);
    DateTime sleepStart;
    if (previousShift != null && previousShift.type == ShiftType.night) {
      // Post-night-shift: sleep from 7 AM
      sleepStart = now.add(const Duration(hours: 7));
    } else {
      // Normal: sleep from 23:00 previous night
      sleepStart = now.subtract(const Duration(hours: 1));
    }

    final sleepEnd = sleepStart.add(const Duration(hours: 9));

    return SleepPlan(
      date: date,
      sleepBlocks: [
        SleepBlock(
          startTime: sleepStart,
          endTime: sleepEnd,
          type: SleepBlockType.core,
        ),
      ],
      strategy: SleepStrategy.offDay,
      sleepDebtHours: sleepDebt,
      recommendation: sleepDebt > 2
          ? 'Recovery day. You have ${sleepDebt.toStringAsFixed(1)}h of sleep debt. Prioritize rest.'
          : 'Off day. Maintain a consistent sleep schedule even on days off.',
    );
  }

  SleepPlan _firstDayPlan(Shift nextShift, DateTime date, double sleepDebt) {
    if (nextShift.type == ShiftType.off) {
      return _offDayPlan(date, null, sleepDebt);
    }

    // No previous shift: assume they can sleep as much as needed before
    final availableEnd = _getAvailableEnd(nextShift);
    final sleepEnd = availableEnd;
    final sleepStart = sleepEnd.subtract(const Duration(hours: 8));

    return SleepPlan(
      date: date,
      shiftId: nextShift.id,
      sleepBlocks: [
        SleepBlock(
          startTime: sleepStart,
          endTime: sleepEnd,
          type: SleepBlockType.core,
        ),
      ],
      strategy: SleepStrategy.singleBlock,
      sleepDebtHours: sleepDebt,
      recommendation: _buildRecommendation(
        nextShift.type,
        SleepStrategy.singleBlock,
        8.0,
      ),
    );
  }

  String _buildRecommendation(
    ShiftType shiftType,
    SleepStrategy strategy,
    double hours,
  ) {
    final buffer = StringBuffer();
    switch (strategy) {
      case SleepStrategy.singleBlock:
        buffer.write('Full sleep block recommended. ');
        break;
      case SleepStrategy.coreWithNap:
        buffer.write('Short turnaround. Get core sleep now, then a 20-min power nap before your shift. ');
        break;
      case SleepStrategy.splitSleep:
        buffer.write('Very tight schedule. Split sleep into two blocks for maximum recovery. ');
        break;
      case SleepStrategy.offDay:
        buffer.write('Recovery day. ');
        break;
    }

    if (shiftType == ShiftType.night) {
      buffer.write('For night shifts, use blackout curtains and keep your room cool (18-20 C).');
    } else if (shiftType == ShiftType.evening) {
      buffer.write('Evening shift allows morning sleep. Avoid caffeine after 14:00.');
    } else {
      buffer.write('Maintain your wind-down routine before sleep.');
    }

    return buffer.toString();
  }

  /// Check if two shifts overlap.
  static bool shiftsOverlap(Shift a, Shift b) {
    final aStart = a.startTime;
    final aEnd = a.isOvernight ? a.endTime.add(const Duration(days: 1)) : a.endTime;
    final bStart = b.startTime;
    final bEnd = b.isOvernight ? b.endTime.add(const Duration(days: 1)) : b.endTime;

    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }

  /// Calculate the gap between two consecutive shifts in hours.
  static double gapBetweenShifts(Shift endingShift, Shift startingShift) {
    final end = endingShift.isOvernight
        ? endingShift.endTime.add(const Duration(days: 1))
        : endingShift.endTime;
    final gap = startingShift.startTime.difference(end);
    return gap.inMinutes / 60.0;
  }
}
