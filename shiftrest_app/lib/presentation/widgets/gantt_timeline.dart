import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/sleep_block.dart';
import '../../domain/models/shift.dart';

/// Gantt-style horizontal timeline showing shifts and sleep blocks.
class GanttTimeline extends StatelessWidget {
  final List<TimelineBlock> blocks;
  final DateTime? currentTime;

  const GanttTimeline({
    super.key,
    required this.blocks,
    this.currentTime,
  });

  /// Create from shifts and sleep blocks.
  factory GanttTimeline.fromData({
    Key? key,
    required List<Shift> shifts,
    required List<SleepBlock> sleepBlocks,
    DateTime? currentTime,
  }) {
    final blocks = <TimelineBlock>[];

    for (final shift in shifts) {
      blocks.add(TimelineBlock(
        start: shift.startTime,
        end: shift.isOvernight ? shift.endTime.add(const Duration(days: 1)) : shift.endTime,
        color: AppColors.tertiary.withValues(alpha: 0.3),
        icon: Icons.work_outline,
        label: 'Shift',
        type: TimelineBlockType.shift,
      ));
    }

    for (final block in sleepBlocks) {
      blocks.add(TimelineBlock(
        start: block.startTime,
        end: block.endTime,
        color: block.type == SleepBlockType.core
            ? AppColors.primary.withValues(alpha: 0.4)
            : AppColors.primary.withValues(alpha: 0.2),
        icon: block.type == SleepBlockType.core ? Icons.bedtime : Icons.snooze,
        label: block.type == SleepBlockType.core ? 'Sleep' : 'Nap',
        type: block.type == SleepBlockType.core ? TimelineBlockType.sleep : TimelineBlockType.nap,
      ));
    }

    return GanttTimeline(
      key: key,
      blocks: blocks,
      currentTime: currentTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = currentTime ?? DateTime.now();

    return Container(
      width: double.infinity,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time rulers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeLabel(context, '00:00'),
              _timeLabel(context, '06:00'),
              _timeLabel(context, '12:00'),
              _timeLabel(context, '18:00'),
              _timeLabel(context, '23:59'),
            ],
          ),
          // Timeline bar
          SizedBox(
            height: 32,
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                // Blocks
                ...blocks.map((b) => _buildBlock(b)),
                // Current time marker
                _buildTimeMarker(now),
              ],
            ),
          ),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _legendItem(context, AppColors.primary, 'Sleep'),
              _legendItem(context, AppColors.tertiary, 'Shift'),
              Text(
                'Now: ${DateFormat('HH:mm').format(now)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.outlineVariant,
            fontSize: 9,
          ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildBlock(TimelineBlock block) {
    final startFraction = _timeToFraction(block.start);
    final endFraction = _timeToFraction(block.end);
    final width = (endFraction - startFraction).clamp(0.02, 1.0);

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                left: constraints.maxWidth * startFraction,
                width: constraints.maxWidth * width,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: block.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Icon(
                      block.icon,
                      size: 14,
                      color: block.type == TimelineBlockType.shift
                          ? AppColors.tertiary
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeMarker(DateTime time) {
    final fraction = _timeToFraction(time);
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: constraints.maxWidth * fraction - 1,
                top: -4,
                bottom: -4,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: AppColors.onSurface,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Positioned(
                left: constraints.maxWidth * fraction - 5,
                top: -6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.onSurface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _timeToFraction(DateTime time) {
    final minutes = time.hour * 60 + time.minute;
    return minutes / (24 * 60);
  }
}

class TimelineBlock {
  final DateTime start;
  final DateTime end;
  final Color color;
  final IconData icon;
  final String label;
  final TimelineBlockType type;

  const TimelineBlock({
    required this.start,
    required this.end,
    required this.color,
    required this.icon,
    required this.label,
    required this.type,
  });
}

enum TimelineBlockType { shift, sleep, nap }
