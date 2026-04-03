import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/shift.dart';

/// 14-day shift calendar grid matching the Stitch dashboard design.
class ShiftCalendar extends StatelessWidget {
  final List<Shift> shifts;
  final DateTime startDate;
  final int days;
  final ValueChanged<DateTime>? onDateTap;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<Shift>? onShiftLongPress;

  const ShiftCalendar({
    super.key,
    required this.shifts,
    required this.startDate,
    this.days = 14,
    this.onDateTap,
    this.onShiftTap,
    this.onShiftLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(days, (i) => startDate.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date range header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Schedule',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${DateFormat('MMM d').format(dates.first)} — ${DateFormat('MMM d').format(dates.last)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    letterSpacing: 2.0,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Day list
        ...dates.map((date) => _buildDayRow(context, date)),
      ],
    );
  }

  Widget _buildDayRow(BuildContext context, DateTime date) {
    final dayShifts = shifts.where((s) {
      final shiftDate = DateTime(s.date.year, s.date.month, s.date.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return shiftDate == targetDate;
    }).toList();

    final isOff = dayShifts.isEmpty || dayShifts.every((s) => s.type == ShiftType.off);
    final isToday = _isToday(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (dayShifts.isNotEmpty && onShiftTap != null) {
            onShiftTap!(dayShifts.first);
          } else if (onDateTap != null) {
            onDateTap!(date);
          }
        },
        onLongPress: dayShifts.isNotEmpty && onShiftLongPress != null
            ? () => onShiftLongPress!(dayShifts.first)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Date column
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    DateFormat('EEE').format(date).substring(0, 3),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isToday ? AppColors.primary : AppColors.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Shift block
            Expanded(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: isOff
                      ? AppColors.surfaceContainerLow
                      : AppColors.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: isOff
                      ? Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.05))
                      : null,
                  boxShadow: isOff
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: isOff
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Off',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.onSurface.withValues(alpha: 0.3),
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                          Icon(
                            Icons.wb_sunny_outlined,
                            color: AppColors.onSurface.withValues(alpha: 0.1),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Shift Duration',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                                      fontSize: 10,
                                      letterSpacing: 2.0,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('HH:mm').format(dayShifts.first.startTime)} — ${DateFormat('HH:mm').format(dayShifts.first.endTime)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.nightlight_round,
                            color: AppColors.onPrimary,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
