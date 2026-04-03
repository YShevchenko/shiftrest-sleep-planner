import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/sleep_plan_provider.dart';

/// Sleep history screen showing planned vs actual sleep.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & History'),
      ),
      body: Consumer<SleepPlanProvider>(
        builder: (context, planProvider, _) {
          final plans = planProvider.plans;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CIRCADIAN INSIGHTS',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 3.0,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sleep History',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    Text(
                      'Last 14 Days',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Legend
                Row(
                  children: [
                    _legendDot(context, AppColors.primary, 'Actual'),
                    const SizedBox(width: 24),
                    _legendDot(context, AppColors.surfaceContainerHighest, 'Planned'),
                  ],
                ),
                const SizedBox(height: 24),

                // History list
                if (plans.isEmpty)
                  _buildEmptyHistory(context)
                else
                  ...plans.map((plan) {
                    final plannedHours = plan.totalPlannedHours;
                    final actualHours = plan.totalActualHours;
                    final hasActual = actualHours > 0;
                    final ratio = hasActual
                        ? (actualHours / plannedHours).clamp(0.0, 1.0)
                        : 0.0;

                    String status;
                    Color? statusColor;
                    if (!hasActual) {
                      status = 'Planned';
                      statusColor = null;
                    } else if (ratio >= 0.9) {
                      status = 'Stable';
                      statusColor = null;
                    } else if (ratio >= 0.7) {
                      status = 'Partial';
                      statusColor = AppColors.tertiary;
                    } else {
                      status = 'Shortfall';
                      statusColor = AppColors.tertiary;
                    }

                    return _buildHistoryEntry(
                      context,
                      date: plan.date,
                      actualHours: hasActual ? actualHours : plannedHours,
                      plannedHours: plannedHours,
                      ratio: hasActual ? ratio : plannedHours / 8.0,
                      status: status,
                      statusColor: statusColor,
                    );
                  }),

                const SizedBox(height: 32),

                // Management section
                Text(
                  'Management',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Export button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.sleepGradient,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export coming soon.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Export Data to JSON',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Icon(Icons.ios_share, color: AppColors.onPrimaryContainer),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Clear data button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showClearDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Clear All Data',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Icon(Icons.delete_forever, color: AppColors.error),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'DATA MANAGEMENT ACTIONS ARE PERMANENT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                          letterSpacing: 2.0,
                          fontSize: 9,
                        ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildHistoryEntry(
    BuildContext context, {
    required DateTime date,
    required double actualHours,
    required double plannedHours,
    required double ratio,
    required String status,
    Color? statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEE d').format(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor ?? AppColors.onSurfaceVariant,
                      letterSpacing: 2.0,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${actualHours.toStringAsFixed(1)}h / ${plannedHours.toStringAsFixed(0)}h',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No sleep history yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your sleep plans will appear here after you accept a recommendation.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your shifts, sleep plans, and history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SleepPlanProvider>().deleteAllPlans();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
