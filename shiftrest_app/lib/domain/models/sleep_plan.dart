import 'package:uuid/uuid.dart';
import 'sleep_block.dart';

/// A daily sleep plan with sleep blocks and naps.
class SleepPlan {
  final String id;
  final DateTime date;
  final String? shiftId;
  final List<SleepBlock> sleepBlocks;
  final SleepStrategy strategy;
  final double? sleepDebtHours;
  final String? recommendation;

  SleepPlan({
    String? id,
    required this.date,
    this.shiftId,
    required this.sleepBlocks,
    required this.strategy,
    this.sleepDebtHours,
    this.recommendation,
  }) : id = id ?? const Uuid().v4();

  /// Total planned sleep duration across all blocks.
  Duration get totalPlannedDuration {
    return sleepBlocks
        .where((b) => b.isPlanned)
        .fold(Duration.zero, (sum, b) => sum + b.duration);
  }

  /// Total actual sleep duration across all blocks.
  Duration get totalActualDuration {
    return sleepBlocks
        .where((b) => !b.isPlanned)
        .fold(Duration.zero, (sum, b) => sum + b.duration);
  }

  double get totalPlannedHours => totalPlannedDuration.inMinutes / 60.0;
  double get totalActualHours => totalActualDuration.inMinutes / 60.0;

  /// Core sleep blocks only.
  List<SleepBlock> get coreBlocks =>
      sleepBlocks.where((b) => b.type == SleepBlockType.core).toList();

  /// Nap blocks only.
  List<SleepBlock> get napBlocks =>
      sleepBlocks.where((b) => b.type == SleepBlockType.nap).toList();

  SleepPlan copyWith({
    String? id,
    DateTime? date,
    String? shiftId,
    List<SleepBlock>? sleepBlocks,
    SleepStrategy? strategy,
    double? sleepDebtHours,
    String? recommendation,
  }) {
    return SleepPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      shiftId: shiftId ?? this.shiftId,
      sleepBlocks: sleepBlocks ?? this.sleepBlocks,
      strategy: strategy ?? this.strategy,
      sleepDebtHours: sleepDebtHours ?? this.sleepDebtHours,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'shiftId': shiftId,
      'strategy': strategy.name,
      'sleepDebtHours': sleepDebtHours,
      'recommendation': recommendation,
    };
  }

  factory SleepPlan.fromMap(
    Map<String, dynamic> map,
    List<SleepBlock> blocks,
  ) {
    return SleepPlan(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      shiftId: map['shiftId'] as String?,
      sleepBlocks: blocks,
      strategy: SleepStrategy.values.firstWhere(
        (e) => e.name == map['strategy'],
        orElse: () => SleepStrategy.singleBlock,
      ),
      sleepDebtHours: (map['sleepDebtHours'] as num?)?.toDouble(),
      recommendation: map['recommendation'] as String?,
    );
  }
}

/// The sleep strategy the algorithm chose.
enum SleepStrategy {
  singleBlock,
  coreWithNap,
  splitSleep,
  offDay;

  String get displayName {
    switch (this) {
      case SleepStrategy.singleBlock:
        return 'Full Sleep';
      case SleepStrategy.coreWithNap:
        return 'Core + Nap';
      case SleepStrategy.splitSleep:
        return 'Split Sleep';
      case SleepStrategy.offDay:
        return 'Recovery Day';
    }
  }

  String get description {
    switch (this) {
      case SleepStrategy.singleBlock:
        return 'You have enough time for a full, unbroken sleep block.';
      case SleepStrategy.coreWithNap:
        return 'Short turnaround detected. Get core sleep plus a power nap before your shift.';
      case SleepStrategy.splitSleep:
        return 'Very tight schedule. Split into two sleep sessions for maximum recovery.';
      case SleepStrategy.offDay:
        return 'Off day — catch up on rest and reset your circadian rhythm.';
    }
  }
}
