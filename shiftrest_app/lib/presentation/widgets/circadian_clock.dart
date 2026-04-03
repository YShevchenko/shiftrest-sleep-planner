import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/services/circadian_model.dart';
import '../../domain/models/shift.dart';
import '../../domain/models/sleep_block.dart';

/// 24-hour circular visualization of the circadian alertness curve
/// with shift and sleep overlays.
class CircadianClock extends StatelessWidget {
  final List<Shift> shifts;
  final List<SleepBlock> sleepBlocks;
  final double size;

  const CircadianClock({
    super.key,
    this.shifts = const [],
    this.sleepBlocks = const [],
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircadianClockPainter(
          alertnessCurve: CircadianModel.generate24HourCurve(),
          shifts: shifts,
          sleepBlocks: sleepBlocks,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.nightlight_round,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                CircadianModel.phaseDescription(DateTime.now().hour.toDouble()),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircadianClockPainter extends CustomPainter {
  final List<AlertnessPoint> alertnessCurve;
  final List<Shift> shifts;
  final List<SleepBlock> sleepBlocks;

  _CircadianClockPainter({
    required this.alertnessCurve,
    required this.shifts,
    required this.sleepBlocks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final innerRadius = outerRadius * 0.55;

    // Draw hour markers
    _drawHourMarkers(canvas, center, outerRadius);

    // Draw alertness curve
    _drawAlertnessCurve(canvas, center, innerRadius, outerRadius);

    // Draw shift overlays
    _drawShiftOverlays(canvas, center, innerRadius, outerRadius);

    // Draw sleep overlays
    _drawSleepOverlays(canvas, center, innerRadius, outerRadius);

    // Draw current time indicator
    _drawCurrentTimeIndicator(canvas, center, innerRadius, outerRadius);
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int hour = 0; hour < 24; hour += 3) {
      final angle = _hourToAngle(hour.toDouble());
      final markerRadius = radius + 2;

      // Tick mark
      final tickStart = Offset(
        center.dx + (radius - 4) * cos(angle),
        center.dy + (radius - 4) * sin(angle),
      );
      final tickEnd = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      canvas.drawLine(
        tickStart,
        tickEnd,
        Paint()
          ..color = AppColors.outlineVariant
          ..strokeWidth = 1,
      );

      // Label
      textPainter.text = TextSpan(
        text: hour.toString().padLeft(2, '0'),
        style: TextStyle(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();

      final labelOffset = Offset(
        center.dx + (markerRadius + 10) * cos(angle) - textPainter.width / 2,
        center.dy + (markerRadius + 10) * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawAlertnessCurve(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
  ) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final bandWidth = outerRadius - innerRadius;

    for (int i = 0; i < alertnessCurve.length; i++) {
      final point = alertnessCurve[i];
      final angle = _hourToAngle(point.hour);
      final r = innerRadius + bandWidth * point.alertness;

      if (i == 0) {
        path.moveTo(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
      } else {
        path.lineTo(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
      }
    }

    // Close with inner circle
    for (int i = alertnessCurve.length - 1; i >= 0; i--) {
      final angle = _hourToAngle(alertnessCurve[i].hour);
      path.lineTo(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
    }

    path.close();
    canvas.drawPath(path, paint);

    // Draw curve outline
    final outlinePath = Path();
    final outlinePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < alertnessCurve.length; i++) {
      final point = alertnessCurve[i];
      final angle = _hourToAngle(point.hour);
      final r = innerRadius + bandWidth * point.alertness;

      if (i == 0) {
        outlinePath.moveTo(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
      } else {
        outlinePath.lineTo(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
      }
    }

    canvas.drawPath(outlinePath, outlinePaint);
  }

  void _drawShiftOverlays(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
  ) {
    for (final shift in shifts) {
      if (shift.type == ShiftType.off) continue;

      final startAngle = _hourToAngle(
        shift.startTime.hour + shift.startTime.minute / 60.0,
      );
      final endHour = shift.isOvernight
          ? shift.endTime.hour + shift.endTime.minute / 60.0 + 24
          : shift.endTime.hour + shift.endTime.minute / 60.0;
      final startHour = shift.startTime.hour + shift.startTime.minute / 60.0;
      final sweepAngle = (endHour - startHour) / 24.0 * 2 * pi;

      final paint = Paint()
        ..color = AppColors.tertiary.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius - 2),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  void _drawSleepOverlays(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
  ) {
    for (final block in sleepBlocks) {
      final startHour = block.startTime.hour + block.startTime.minute / 60.0;
      final endHour = block.endTime.hour + block.endTime.minute / 60.0;
      final startAngle = _hourToAngle(startHour);
      var hours = endHour - startHour;
      if (hours < 0) hours += 24;
      final sweepAngle = hours / 24.0 * 2 * pi;

      final paint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  void _drawCurrentTimeIndicator(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
  ) {
    final now = DateTime.now();
    final hour = now.hour + now.minute / 60.0;
    final angle = _hourToAngle(hour);

    final paint = Paint()
      ..color = AppColors.onSurface
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(
        center.dx + (innerRadius - 8) * cos(angle),
        center.dy + (innerRadius - 8) * sin(angle),
      ),
      Offset(
        center.dx + (outerRadius + 2) * cos(angle),
        center.dy + (outerRadius + 2) * sin(angle),
      ),
      paint,
    );

    // Dot at the end
    canvas.drawCircle(
      Offset(
        center.dx + (outerRadius + 2) * cos(angle),
        center.dy + (outerRadius + 2) * sin(angle),
      ),
      4,
      Paint()..color = AppColors.onSurface,
    );
  }

  /// Convert hour (0-24) to angle in radians.
  /// 0h (midnight) is at the top (- pi/2).
  double _hourToAngle(double hour) {
    return (hour / 24.0) * 2 * pi - pi / 2;
  }

  @override
  bool shouldRepaint(covariant _CircadianClockPainter oldDelegate) => true;
}
