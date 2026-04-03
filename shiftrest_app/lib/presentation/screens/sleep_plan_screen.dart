import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/sleep_block.dart';
import '../../domain/models/sleep_plan.dart';
import '../../services/health_service.dart';
import '../providers/settings_provider.dart';
import '../providers/shift_provider.dart';
import '../providers/sleep_plan_provider.dart';
import '../widgets/gantt_timeline.dart';
import '../widgets/sleep_block_widget.dart';

const _kSleepTags = ['Noisy', 'Caffeine', 'Stress', 'Sick', 'Alcohol', 'Exercise'];

/// Sleep planner screen with Gantt timeline and recommendations.
class SleepPlanScreen extends StatelessWidget {
  const SleepPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<SleepPlanProvider, ShiftProvider>(
        builder: (context, planProvider, shiftProvider, _) {
          final plan = planProvider.currentPlan;

          if (shiftProvider.shifts.isEmpty) {
            return _buildEmptyState(context);
          }

          if (plan == null) {
            // Auto-calculate if shifts exist
            WidgetsBinding.instance.addPostFrameCallback((_) {
              planProvider.calculatePlans(shiftProvider.shifts);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Text(
                  'UPCOMING SCHEDULE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your next shift...',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),

                // Main recommendation card
                _buildRecommendationCard(context, plan),

                const SizedBox(height: 24),

                // Accept & Set Alarm button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.sleepGradient,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptPlan(context, plan),
                      icon: const Icon(Icons.alarm_add, color: AppColors.onPrimaryContainer),
                      label: Text(
                        'Accept & Set Alarm',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Sleep blocks
                Text(
                  'Sleep Blocks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  plan.strategy.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ...plan.sleepBlocks.map((block) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SleepBlockWidget(
                        block: block,
                        onTap: () => _showLogSleepDialog(context, plan, block),
                      ),
                    )),

                const SizedBox(height: 24),

                // Timeline section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timeline View',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Your circadian distribution',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.info_outline,
                      color: AppColors.outlineVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GanttTimeline.fromData(
                  shifts: shiftProvider.shifts.take(2).toList(),
                  sleepBlocks: plan.sleepBlocks,
                ),

                const SizedBox(height: 24),

                // Recommendation text
                if (plan.recommendation != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: AppColors.tertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plan.recommendation!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
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

  Widget _buildRecommendationCard(BuildContext context, SleepPlan plan) {
    final mainBlock = plan.coreBlocks.isNotEmpty ? plan.coreBlocks.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Icon(
                Icons.bedtime,
                color: AppColors.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'RECOMMENDED',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sleep Window',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 8),
              if (mainBlock != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(mainBlock.startTime),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '—',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.outline,
                            ),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(mainBlock.endTime),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppColors.tertiary,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${plan.totalPlannedHours.toStringAsFixed(1)}h',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_outlined,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'No shifts entered yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your shifts in the Schedule tab and we will calculate your optimal sleep windows.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _acceptPlan(BuildContext context, SleepPlan plan) async {
    await context.read<SleepPlanProvider>().savePlan(plan);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep plan saved. Alarm set.')),
      );
    }
  }

  void _showLogSleepDialog(
      BuildContext context, SleepPlan plan, SleepBlock block) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _LogSleepDialog(plan: plan, block: block),
    );
  }
}

class _LogSleepDialog extends StatefulWidget {
  final SleepPlan plan;
  final SleepBlock block;

  const _LogSleepDialog({required this.plan, required this.block});

  @override
  State<_LogSleepDialog> createState() => _LogSleepDialogState();
}

class _LogSleepDialogState extends State<_LogSleepDialog> {
  int _rating = 0;
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _rating = widget.block.qualityRating ?? 0;
    _selectedTags.addAll(widget.block.tags);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Sleep Quality'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality Rating',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 2.0,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    _rating >= star ? Icons.star : Icons.star_border,
                    color: AppColors.tertiary,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 2.0,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kSleepTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (on) => setState(() {
                    if (on) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  }),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final updated = widget.block.copyWith(
              isPlanned: false,
              qualityRating: _rating > 0 ? _rating : null,
              tags: _selectedTags.toList(),
            );
            await context
                .read<SleepPlanProvider>()
                .logActualSleep(widget.plan.id, updated);

            // Sync to Health Connect if the user has enabled it
            if (context.mounted) {
              final healthSync =
                  context.read<SettingsProvider>().healthSync;
              if (healthSync) {
                await HealthService.writeSleepSession(
                  start: updated.startTime,
                  end: updated.endTime,
                );
              }
            }

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sleep logged.')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
