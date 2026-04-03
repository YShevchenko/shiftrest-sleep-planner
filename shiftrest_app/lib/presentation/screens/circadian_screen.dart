import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/services/circadian_model.dart';
import '../providers/shift_provider.dart';
import '../providers/sleep_plan_provider.dart';
import '../widgets/circadian_clock.dart';

/// Circadian visualization screen with 24h clock.
class CircadianScreen extends StatelessWidget {
  const CircadianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circadian Rhythm'),
      ),
      body: Consumer2<ShiftProvider, SleepPlanProvider>(
        builder: (context, shiftProvider, planProvider, _) {
          final currentPlan = planProvider.currentPlan;
          final now = DateTime.now();
          final currentAlertness = CircadianModel.alertnessAtHour(
            now.hour + now.minute / 60.0,
          );
          final phase = CircadianModel.phaseDescription(
            now.hour + now.minute / 60.0,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header
                Text(
                  'YOUR CIRCADIAN CLOCK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.7),
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 32),
                // Clock visualization
                CircadianClock(
                  shifts: shiftProvider.shifts,
                  sleepBlocks: currentPlan?.sleepBlocks ?? [],
                  size: MediaQuery.of(context).size.width - 80,
                ),
                const SizedBox(height: 32),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem(context, AppColors.primary.withValues(alpha: 0.4), 'Alertness'),
                    const SizedBox(width: 24),
                    _legendItem(context, AppColors.tertiary.withValues(alpha: 0.3), 'Shift'),
                    const SizedBox(width: 24),
                    _legendItem(context, AppColors.primary.withValues(alpha: 0.3), 'Sleep'),
                  ],
                ),
                const SizedBox(height: 32),
                // Current phase card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Phase',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phase,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Alertness bar
                      Row(
                        children: [
                          Text(
                            'Alertness',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: currentAlertness,
                                backgroundColor: AppColors.surfaceContainerHighest,
                                valueColor:
                                    AlwaysStoppedAnimation(AppColors.primary),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(currentAlertness * 100).round()}%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Info cards
                _buildInfoCard(
                  context,
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Optimal Nap Window',
                  body:
                      'Your natural alertness dip occurs around 14:00. This is the ideal time for a power nap.',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.nightlight_round,
                  title: 'Deep Sleep Window',
                  body:
                      'Your deepest sleep drive occurs between 01:00 - 05:00. Sleep during this window is most restorative.',
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.tertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
