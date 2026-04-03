import 'package:uuid/uuid.dart';

/// Represents a work shift.
class Shift {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final ShiftType type;
  final int commuteMinutes;
  final String? notes;

  Shift({
    String? id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.commuteMinutes = 30,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  /// Duration of the shift.
  Duration get duration {
    if (endTime.isAfter(startTime)) {
      return endTime.difference(startTime);
    }
    // Overnight shift: end is next day
    return endTime.add(const Duration(days: 1)).difference(startTime);
  }

  /// Whether this shift crosses midnight.
  bool get isOvernight => endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime);

  Shift copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    ShiftType? type,
    int? commuteMinutes,
    String? notes,
  }) {
    return Shift(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      commuteMinutes: commuteMinutes ?? this.commuteMinutes,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type.name,
      'commuteMinutes': commuteMinutes,
      'notes': notes,
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      type: ShiftType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ShiftType.day,
      ),
      commuteMinutes: map['commuteMinutes'] as int? ?? 30,
      notes: map['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shift && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Shift(id: $id, date: $date, start: $startTime, end: $endTime, type: ${type.name})';
}

enum ShiftType {
  day,
  evening,
  night,
  off;

  String get displayName {
    switch (this) {
      case ShiftType.day:
        return 'Day';
      case ShiftType.evening:
        return 'Evening';
      case ShiftType.night:
        return 'Night';
      case ShiftType.off:
        return 'Off';
    }
  }

  String get icon {
    switch (this) {
      case ShiftType.day:
        return 'light_mode';
      case ShiftType.evening:
        return 'routine';
      case ShiftType.night:
        return 'bedtime';
      case ShiftType.off:
        return 'sunny';
    }
  }
}
