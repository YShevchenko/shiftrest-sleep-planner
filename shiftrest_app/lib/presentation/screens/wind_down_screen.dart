import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/wind_down_routine.dart';

/// Wind-down routine countdown screen.
class WindDownScreen extends StatefulWidget {
  const WindDownScreen({super.key});

  @override
  State<WindDownScreen> createState() => _WindDownScreenState();
}

class _WindDownScreenState extends State<WindDownScreen>
    with TickerProviderStateMixin {
  final WindDownRoutine _routine = WindDownRoutine.defaultRoutine;
  int _currentStepIndex = 0;
  int _stepSecondsRemaining = 0;
  bool _isRunning = false;
  Timer? _timer;
  late AnimationController _dimController;

  @override
  void initState() {
    super.initState();
    _dimController = AnimationController(
      vsync: this,
      duration: Duration(minutes: _routine.durationMinutes),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dimController.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _currentStepIndex = 0;
      _stepSecondsRemaining = _routine.steps[0].durationMinutes * 60;
    });
    _dimController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _stepSecondsRemaining--;
        if (_stepSecondsRemaining <= 0) {
          if (_currentStepIndex < _routine.steps.length - 1) {
            _currentStepIndex++;
            _stepSecondsRemaining =
                _routine.steps[_currentStepIndex].durationMinutes * 60;
          } else {
            _stop();
          }
        }
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    _dimController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screen dims as routine progresses
    final dimValue = _isRunning ? _dimController.value : 0.0;
    final bgOpacity = (1.0 - dimValue * 0.7).clamp(0.3, 1.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Wind Down'),
        backgroundColor: AppColors.surface,
      ),
      body: AnimatedBuilder(
        animation: _dimController,
        builder: (context, child) {
          return Opacity(
            opacity: bgOpacity,
            child: child,
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'WIND-DOWN ROUTINE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prepare for sleep',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_routine.durationMinutes} minute routine',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),

              if (!_isRunning) ...[
                // Step preview list
                ..._routine.steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return _buildStepCard(context, index, step, false);
                }),
                const SizedBox(height: 32),
                // Start button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.sleepGradient,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.play_arrow, color: AppColors.onPrimaryContainer),
                      label: Text(
                        'Begin Routine',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
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
              ] else ...[
                // Active routine
                _buildActiveStep(context),
                const SizedBox(height: 32),
                // Progress
                _buildProgress(context),
                const SizedBox(height: 32),
                // Cancel
                Center(
                  child: TextButton(
                    onPressed: _stop,
                    child: Text(
                      'End Routine',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    int index,
    WindDownStep step,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStepIcon(step.icon),
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${step.durationMinutes} min',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStep(BuildContext context) {
    final step = _routine.steps[_currentStepIndex];
    final minutes = _stepSecondsRemaining ~/ 60;
    final seconds = _stepSecondsRemaining % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStepIcon(step.icon),
            color: AppColors.primary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Step ${_currentStepIndex + 1} of ${_routine.steps.length}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '${_currentStepIndex + 1}/${_routine.steps.length}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStepIndex + 1) / _routine.steps.length,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  IconData _getStepIcon(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return Icons.lightbulb_outlined;
      case 'phone_disabled':
        return Icons.phone_disabled_outlined;
      case 'air':
        return Icons.air;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'thermostat':
        return Icons.thermostat_outlined;
      case 'bedtime':
        return Icons.bedtime_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
