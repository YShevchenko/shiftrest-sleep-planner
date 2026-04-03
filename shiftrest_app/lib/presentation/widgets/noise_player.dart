import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/noise_preset.dart';

/// Noise player controls for Dark Room and general use.
class NoisePlayer extends StatelessWidget {
  final NoiseType selectedType;
  final double volume;
  final bool isPlaying;
  final ValueChanged<NoiseType> onTypeChanged;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onTogglePlay;
  final bool useDarkRoomStyle;

  const NoisePlayer({
    super.key,
    required this.selectedType,
    required this.volume,
    required this.isPlaying,
    required this.onTypeChanged,
    required this.onVolumeChanged,
    required this.onTogglePlay,
    this.useDarkRoomStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = useDarkRoomStyle ? AppColors.darkRoomRedText : AppColors.primary;
    final dimColor = useDarkRoomStyle
        ? AppColors.darkRoomRedDim
        : AppColors.surfaceContainerHighest;
    final textColor = useDarkRoomStyle
        ? AppColors.darkRoomRed
        : AppColors.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Stop button
        GestureDetector(
          onTap: onTogglePlay,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: useDarkRoomStyle ? Colors.black : AppColors.surfaceContainerHigh,
              border: Border.all(
                color: activeColor.withValues(alpha: isPlaying ? 0.8 : 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isPlaying ? Icons.waves : Icons.play_arrow,
              color: activeColor,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Noise type selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: NoiseType.values
              .where((t) => t != NoiseType.off)
              .map((type) => _noiseTypeChip(context, type, activeColor, dimColor, textColor))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Volume label
        Text(
          selectedType.displayName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                letterSpacing: 2.0,
              ),
        ),
        const SizedBox(height: 12),
        // Volume slider
        SizedBox(
          width: 200,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: dimColor,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: volume,
              onChanged: onVolumeChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _noiseTypeChip(
    BuildContext context,
    NoiseType type,
    Color activeColor,
    Color dimColor,
    Color textColor,
  ) {
    final isSelected = type == selectedType;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.15) : dimColor,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: activeColor.withValues(alpha: 0.5))
                : null,
          ),
          child: Text(
            type.displayName.split(' ').first,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? activeColor : textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}
