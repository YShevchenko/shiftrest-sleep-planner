import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/services/circadian_model.dart';
import '../widgets/nap_timer.dart';

/// Quick nap timer screen with sleep debt info.
class NapScreen extends StatelessWidget {
  const NapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentAlertness = CircadianModel.alertnessAtHour(
      now.hour + now.minute / 60.0,
    );
    final optimalNapHour = CircadianModel.optimalNapHour();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nap Optimizer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            Text(
              'NAP OPTIMIZER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quick Recovery',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),

            // Alertness indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Alertness',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '${(currentAlertness * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: currentAlertness < 0.4
                                  ? AppColors.error
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentAlertness,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        currentAlertness < 0.4 ? AppColors.error : AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  if (currentAlertness < 0.5) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.tertiary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your alertness is low. A nap would be beneficial right now.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.tertiary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Optimal nap window
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.tertiary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Optimal nap window: ${optimalNapHour.toInt()}:00. Your natural alertness dip makes this the best time.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nap timer
            NapTimer(
              onComplete: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nap complete! Time to get moving.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
