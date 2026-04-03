import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/sleep_block.dart';

/// Visual representation of a sleep block.
class SleepBlockWidget extends StatelessWidget {
  final SleepBlock block;
  final VoidCallback? onTap;

  const SleepBlockWidget({
    super.key,
    required this.block,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNap = block.type == SleepBlockType.nap;
    final hours = block.durationHours;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNap
              ? AppColors.surfaceContainerLow
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNap
                ? AppColors.tertiary.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isNap
                    ? AppColors.tertiary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isNap ? Icons.snooze : Icons.bedtime,
                color: isNap ? AppColors.tertiary : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            // Time info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.type.displayName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                          letterSpacing: 2.0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('HH:mm').format(block.startTime)} — ${DateFormat('HH:mm').format(block.endTime)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceBright.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${hours.toStringAsFixed(1)}h',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
