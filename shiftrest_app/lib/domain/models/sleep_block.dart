import 'package:uuid/uuid.dart';

/// A single block of sleep (core or nap), planned or actual.
class SleepBlock {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final SleepBlockType type;
  final bool isPlanned;
  final int? qualityRating; // 1-5
  final List<String> tags; // e.g. noisy, caffeine, stress, sick, alcohol, exercise

  SleepBlock({
    String? id,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.isPlanned = true,
    this.qualityRating,
    List<String>? tags,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? const [];

  Duration get duration => endTime.difference(startTime);

  double get durationHours => duration.inMinutes / 60.0;

  SleepBlock copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    SleepBlockType? type,
    bool? isPlanned,
    int? qualityRating,
    List<String>? tags,
  }) {
    return SleepBlock(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      isPlanned: isPlanned ?? this.isPlanned,
      qualityRating: qualityRating ?? this.qualityRating,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type.name,
      'isPlanned': isPlanned ? 1 : 0,
      'qualityRating': qualityRating,
      'tags': tags.isNotEmpty ? tags.join(',') : null,
    };
  }

  factory SleepBlock.fromMap(Map<String, dynamic> map) {
    final tagsRaw = map['tags'] as String?;
    final parsedTags = (tagsRaw != null && tagsRaw.isNotEmpty)
        ? tagsRaw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
        : <String>[];

    return SleepBlock(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      type: SleepBlockType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SleepBlockType.core,
      ),
      isPlanned: (map['isPlanned'] as int?) == 1,
      qualityRating: map['qualityRating'] as int?,
      tags: parsedTags,
    );
  }

  @override
  String toString() =>
      'SleepBlock(${type.name}: $startTime - $endTime, ${isPlanned ? "planned" : "actual"})';
}

enum SleepBlockType {
  core,
  nap;

  String get displayName {
    switch (this) {
      case SleepBlockType.core:
        return 'Core Sleep';
      case SleepBlockType.nap:
        return 'Nap';
    }
  }
}
