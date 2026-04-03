import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/shift.dart';

enum RepeatOption { none, daily, weekly }

extension RepeatOptionLabel on RepeatOption {
  String get label {
    switch (this) {
      case RepeatOption.none:
        return 'No Repeat';
      case RepeatOption.daily:
        return 'Daily';
      case RepeatOption.weekly:
        return 'Weekly';
    }
  }
}

/// Dialog for adding or editing a shift.
class ShiftEntryDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Shift? existingShift;

  const ShiftEntryDialog({
    super.key,
    required this.selectedDate,
    this.existingShift,
  });

  @override
  State<ShiftEntryDialog> createState() => _ShiftEntryDialogState();
}

class _ShiftEntryDialogState extends State<ShiftEntryDialog> {
  late ShiftType _selectedType;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _commuteMinutes;
  RepeatOption _repeatOption = RepeatOption.none;

  @override
  void initState() {
    super.initState();
    if (widget.existingShift != null) {
      _selectedType = widget.existingShift!.type;
      _startTime = TimeOfDay.fromDateTime(widget.existingShift!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.existingShift!.endTime);
      _commuteMinutes = widget.existingShift!.commuteMinutes;
    } else {
      _selectedType = ShiftType.night;
      _startTime = const TimeOfDay(hour: 22, minute: 0);
      _endTime = const TimeOfDay(hour: 6, minute: 0);
      _commuteMinutes = 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingShift != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Header
            Text(
              'New Entry',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 3.0,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isEditing ? 'Edit Shift' : "Tonight's Rhythm.",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: -1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, y').format(widget.selectedDate),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            // Time inputs
            Row(
              children: [
                Expanded(
                  child: _timeInput(
                    context,
                    'Start Time',
                    _startTime,
                    (t) => setState(() => _startTime = t),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _timeInput(
                    context,
                    'End Time',
                    _endTime,
                    (t) => setState(() => _endTime = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Shift type
            Text(
              'SHIFT CATEGORY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 3.0,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _typeButton(context, ShiftType.day, Icons.light_mode_outlined),
                const SizedBox(width: 8),
                _typeButton(context, ShiftType.evening, Icons.wb_twilight),
                const SizedBox(width: 8),
                _typeButton(context, ShiftType.night, Icons.nightlight_round),
                const SizedBox(width: 8),
                _typeButton(context, ShiftType.off, Icons.wb_sunny_outlined),
              ],
            ),
            const SizedBox(height: 32),
            // Commute time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMMUTE TIME',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            letterSpacing: 3.0,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_commuteMinutes mins',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                Icon(
                  Icons.directions_car,
                  color: AppColors.tertiary,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _commuteMinutes.toDouble(),
              min: 0,
              max: 120,
              divisions: 24,
              onChanged: (v) => setState(() => _commuteMinutes = v.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 MIN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        fontSize: 9,
                      ),
                ),
                Text(
                  '120 MIN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        fontSize: 9,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Repeat option (only for new shifts)
            if (!isEditing) ...[
              Text(
                'REPEAT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      letterSpacing: 3.0,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RepeatOption>(
                    value: _repeatOption,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceContainerHigh,
                    items: RepeatOption.values
                        .map((opt) => DropdownMenuItem(
                              value: opt,
                              child: Text(opt.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _repeatOption = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            // Save button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.sleepGradient,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    isEditing ? 'Update Shift' : 'Save Shift',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop('delete'),
                  child: Text(
                    'Delete Shift',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.error,
                        ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _timeInput(
    BuildContext context,
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 3.0,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _typeButton(BuildContext context, ShiftType type, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.onPrimary
                    : (type == ShiftType.off ? AppColors.tertiary : AppColors.primary),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                type.displayName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final date = widget.selectedDate;
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      _startTime.hour,
      _startTime.minute,
    );
    var endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      _endTime.hour,
      _endTime.minute,
    );

    // If end time is before start time, it's the next day
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final baseShift = Shift(
      id: widget.existingShift?.id,
      date: date,
      startTime: startDateTime,
      endTime: endDateTime,
      type: _selectedType,
      commuteMinutes: _commuteMinutes,
    );

    // Build repeated shifts if requested
    if (_repeatOption != RepeatOption.none && widget.existingShift == null) {
      final stepDays = _repeatOption == RepeatOption.daily ? 1 : 7;
      final copies = _repeatOption == RepeatOption.daily ? 6 : 3; // 7 days or 4 weeks
      final List<Shift> allShifts = [baseShift];
      for (int i = 1; i <= copies; i++) {
        final offset = i * stepDays;
        allShifts.add(Shift(
          id: const Uuid().v4(),
          date: date.add(Duration(days: offset)),
          startTime: startDateTime.add(Duration(days: offset)),
          endTime: endDateTime.add(Duration(days: offset)),
          type: _selectedType,
          commuteMinutes: _commuteMinutes,
        ));
      }
      Navigator.of(context).pop(allShifts);
      return;
    }

    Navigator.of(context).pop(baseShift);
  }
}
