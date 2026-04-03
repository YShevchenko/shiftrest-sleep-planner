import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/shift.dart';
import '../providers/shift_provider.dart';
import '../providers/sleep_plan_provider.dart';
import '../widgets/shift_calendar.dart';
import '../widgets/shift_entry_dialog.dart';
import 'package:uuid/uuid.dart';

/// 14-day shift calendar screen.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().loadShifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ShiftProvider>(
        builder: (context, shiftProvider, _) {
          if (shiftProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                title: Text(
                  'NOCTURNAL SANCTUARY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.account_circle_outlined, color: AppColors.primary),
                ),
              ),
              // Summary card
              if (shiftProvider.nextShift != null)
                SliverToBoxAdapter(
                  child: _buildSummaryCard(context, shiftProvider.nextShift!),
                ),
              // Calendar
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: ShiftCalendar(
                    shifts: shiftProvider.shifts,
                    startDate: _startDate,
                    days: 14,
                    onDateTap: (date) => _showAddShift(context, date),
                    onShiftTap: (shift) => _showEditShift(context, shift),
                    onShiftLongPress: (shift) => _showCloneDialog(context, shift),
                  ),
                ),
              ),
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.sleepGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddShift(context, DateTime.now()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 28, color: AppColors.onPrimaryContainer),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Shift nextShift) {
    final now = DateTime.now();
    final prepTime = nextShift.startTime.subtract(
      Duration(minutes: nextShift.commuteMinutes + 30),
    );
    final timeUntilPrep = prepTime.difference(now);

    String prepString;
    if (timeUntilPrep.isNegative) {
      prepString = 'Shift is active';
    } else if (timeUntilPrep.inHours > 0) {
      prepString = 'Prep begins in ${timeUntilPrep.inHours}h ${timeUntilPrep.inMinutes % 60}m';
    } else {
      prepString = 'Prep begins in ${timeUntilPrep.inMinutes}m';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 64,
            offset: const Offset(0, 32),
          ),
        ],
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Stack(
        children: [
          // Glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UPCOMING SHIFT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${nextShift.type.displayName} Shift starts at ${DateFormat('HH:mm').format(nextShift.startTime)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  prepString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.8),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddShift(BuildContext ctx, DateTime date) async {
    final result = await showModalBottomSheet<dynamic>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShiftEntryDialog(selectedDate: date),
    );

    if (!mounted) return;
    final provider = context.read<ShiftProvider>();

    if (result is List<Shift>) {
      // Repeated shifts
      for (final shift in result) {
        await provider.addShift(shift);
      }
    } else if (result is Shift) {
      await provider.addShift(result);
    } else {
      return;
    }

    if (!mounted) return;
    _recalculatePlans();
  }

  void _showEditShift(BuildContext ctx, Shift shift) async {
    final result = await showModalBottomSheet<dynamic>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShiftEntryDialog(
        selectedDate: shift.date,
        existingShift: shift,
      ),
    );

    if (!mounted) return;
    final provider = context.read<ShiftProvider>();

    if (result is Shift) {
      await provider.updateShift(result);
    } else if (result == 'delete') {
      await provider.deleteShift(shift.id);
    } else {
      return;
    }
    if (!mounted) return;
    _recalculatePlans();
  }

  void _recalculatePlans() {
    final shifts = context.read<ShiftProvider>().shifts;
    context.read<SleepPlanProvider>().calculatePlans(shifts);
  }

  void _showCloneDialog(BuildContext ctx, Shift shift) {
    DateTime targetDate = shift.date.add(const Duration(days: 1));

    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Clone Shift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Copy "${shift.type.displayName}" shift to:',
                style: Theme.of(dialogCtx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEE, MMM d, y').format(targetDate),
                      style: Theme.of(dialogCtx).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: dialogCtx,
                        initialDate: targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => targetDate = picked);
                      }
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setDialogState(() => targetDate =
                          shift.date.add(const Duration(days: 1)));
                    },
                    child: const Text('+1 Day'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setDialogState(() => targetDate =
                          shift.date.add(const Duration(days: 7)));
                    },
                    child: const Text('+1 Week'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await _cloneShiftToDate(shift, targetDate);
              },
              child: const Text('Clone'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cloneShiftToDate(Shift original, DateTime targetDate) async {
    final offsetDays = targetDate.difference(original.date).inDays;
    final cloned = Shift(
      id: const Uuid().v4(),
      date: targetDate,
      startTime: original.startTime.add(Duration(days: offsetDays)),
      endTime: original.endTime.add(Duration(days: offsetDays)),
      type: original.type,
      commuteMinutes: original.commuteMinutes,
      notes: original.notes,
    );

    if (!mounted) return;
    final provider = context.read<ShiftProvider>();
    await provider.addShift(cloned);
    if (!mounted) return;
    _recalculatePlans();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shift cloned to ${DateFormat('EEE, MMM d').format(targetDate)}.',
        ),
      ),
    );
  }
}
