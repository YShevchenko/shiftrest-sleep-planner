import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';

/// Countdown nap timer widget.
class NapTimer extends StatefulWidget {
  final VoidCallback? onComplete;

  const NapTimer({super.key, this.onComplete});

  @override
  State<NapTimer> createState() => _NapTimerState();
}

class _NapTimerState extends State<NapTimer> with TickerProviderStateMixin {
  int _selectedMinutes = 20;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _stop();
          widget.onComplete?.call();
        }
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (!_isRunning || _selectedMinutes == 0) return 0;
    return 1.0 - (_remainingSeconds / (_selectedMinutes * 60));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isRunning) ...[
          // Duration selector
          Text(
            'QUICK NAP',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: AppConstants.napDurations.map((minutes) {
              final isSelected = _selectedMinutes == minutes;
              return GestureDetector(
                onTap: () => setState(() => _selectedMinutes = minutes),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$minutes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : AppColors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        'min',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimary.withValues(alpha: 0.7)
                                  : AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            _napDescription(_selectedMinutes),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Start button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.sleepGradient,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text(
                  'Start $_selectedMinutes-min Nap',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ),
        ] else ...[
          // Running timer
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.2 + 0.1 * _pulseController.value,
                    ),
                    width: 3,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 6,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'remaining',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: _stop,
            child: Text(
              'Cancel Nap',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  String _napDescription(int minutes) {
    switch (minutes) {
      case 10:
        return 'Micro nap. Boosts alertness without grogginess.';
      case 20:
        return 'Power nap. Ideal for quick recovery between shifts.';
      case 26:
        return 'NASA nap. Proven to improve performance by 34%.';
      case 90:
        return 'Full cycle. One complete sleep cycle for deep recovery.';
      default:
        return 'Custom nap duration.';
    }
  }
}
