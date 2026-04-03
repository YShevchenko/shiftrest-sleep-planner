import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/noise_preset.dart';
import '../providers/dark_room_provider.dart';
import '../widgets/noise_player.dart';

/// Dark Room screen - pure black with dim red clock and noise controls.
class DarkRoomScreen extends StatefulWidget {
  const DarkRoomScreen({super.key});

  @override
  State<DarkRoomScreen> createState() => _DarkRoomScreenState();
}

class _DarkRoomScreenState extends State<DarkRoomScreen> {
  @override
  void initState() {
    super.initState();
    // Enable wakelock and immersive mode
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DarkRoomProvider>().activate();
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkRoomProvider>(
      builder: (context, provider, _) {
        final time = provider.currentTime;
        final timeString =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

        return Scaffold(
          backgroundColor: AppColors.darkRoomBackground,
          body: GestureDetector(
            onTap: provider.tapScreen,
            child: Stack(
              children: [
                // Subtle radial glow
                Center(
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.darkRoomRed.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Column(
                  children: [
                    // Top bar (fades in/out)
                    AnimatedOpacity(
                      opacity: provider.controlsVisible ? 1.0 : 0.1,
                      duration: const Duration(milliseconds: 700),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      provider.deactivate();
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.darkRoomRedDim,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'DARK ROOM',
                                    style: TextStyle(
                                      color: AppColors.darkRoomRed,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 3.0,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'NOCTURNAL',
                                style: TextStyle(
                                  color: AppColors.darkRoomRedDim.withValues(alpha: 0.3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Clock face
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeString,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 120,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkRoomRed.withValues(alpha: 0.4),
                                letterSpacing: -4,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (provider.alarmSet && provider.timeUntilAlarm != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.alarm,
                                    color: AppColors.darkRoomRedDim,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Alarm in ${_formatDuration(provider.timeUntilAlarm!)}',
                                    style: TextStyle(
                                      color: AppColors.darkRoomRedDim.withValues(alpha: 0.6),
                                      fontSize: 12,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Noise controls (fade in/out)
                    AnimatedOpacity(
                      opacity: provider.controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 700),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: NoisePlayer(
                          selectedType: provider.noiseType,
                          volume: provider.volume,
                          isPlaying: provider.isPlaying,
                          onTypeChanged: provider.setNoiseType,
                          onVolumeChanged: provider.setVolume,
                          onTogglePlay: () {
                            if (provider.isPlaying) {
                              provider.noiseService.stop();
                            } else {
                              if (provider.noiseType == NoiseType.off) {
                                provider.setNoiseType(NoiseType.white);
                              }
                              provider.noiseService.play();
                            }
                          },
                          useDarkRoomStyle: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Wake alarm setter
                    AnimatedOpacity(
                      opacity: provider.controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 700),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildAlarmSetter(context, provider),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Slide to wake
                    AnimatedOpacity(
                      opacity: provider.controlsVisible ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 700),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildSlideToWake(context, provider),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlarmSetter(BuildContext context, DarkRoomProvider provider) {
    if (provider.alarmSet) {
      return TextButton(
        onPressed: provider.cancelAlarm,
        child: Text(
          'Cancel Alarm',
          style: TextStyle(
            color: AppColors.darkRoomRedText,
            fontSize: 12,
            letterSpacing: 2.0,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      children: [1, 2, 3, 4, 6, 8].map((hours) {
        return GestureDetector(
          onTap: () => provider.setAlarm(Duration(hours: hours)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkRoomRedDim.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${hours}h',
              style: TextStyle(
                color: AppColors.darkRoomRed,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlideToWake(BuildContext context, DarkRoomProvider provider) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          provider.deactivate();
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: AppColors.darkRoomRedDim.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkRoomRed.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.darkRoomRedDim.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_double_arrow_right,
                color: AppColors.darkRoomRed.withValues(alpha: 0.6),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'SLIDE TO WAKE UP',
                  style: TextStyle(
                    color: AppColors.darkRoomRedDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
