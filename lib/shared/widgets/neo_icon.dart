import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum NeoIconType {
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  play,
  pause,
  heart,
  coin,
  star,
  lock,
  undo,
  hint,
  refresh,
  settings,
  trophy,
  stopwatch,
  checkmark,
  gift,
  chevronLeft,
  chevronRight,
  user,
}

/// Custom Vector Icon Renderer conforming strictly to the Vector Icon Policy.
/// Zero system emojis; pure hardware-accelerated vector rendering.
class NeoIcon extends StatelessWidget {
  final NeoIconType type;
  final double size;
  final Color? color;

  const NeoIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NeoIconPainter(type: type, color: effectiveColor),
      ),
    );
  }
}

class _NeoIconPainter extends CustomPainter {
  final NeoIconType type;
  final Color color;

  _NeoIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case NeoIconType.arrowUp:
      case NeoIconType.arrowDown:
      case NeoIconType.arrowLeft:
      case NeoIconType.arrowRight:
        _drawArrow(canvas, size, paint, fillPaint);
        break;

      case NeoIconType.play:
        final path = Path()
          ..moveTo(w * 0.3, h * 0.2)
          ..lineTo(w * 0.8, h * 0.5)
          ..lineTo(w * 0.3, h * 0.8)
          ..close();
        canvas.drawPath(path, fillPaint);
        break;

      case NeoIconType.pause:
        paint.strokeWidth = w * 0.16;
        canvas.drawLine(Offset(w * 0.35, h * 0.25), Offset(w * 0.35, h * 0.75), paint);
        canvas.drawLine(Offset(w * 0.65, h * 0.25), Offset(w * 0.65, h * 0.75), paint);
        break;

      case NeoIconType.heart:
        final path = Path()
          ..moveTo(w * 0.5, h * 0.8)
          ..cubicTo(w * 0.1, h * 0.55, w * 0.1, h * 0.25, w * 0.3, h * 0.2)
          ..cubicTo(w * 0.42, h * 0.18, w * 0.5, h * 0.3, w * 0.5, h * 0.3)
          ..cubicTo(w * 0.5, h * 0.3, w * 0.58, h * 0.18, w * 0.7, h * 0.2)
          ..cubicTo(w * 0.9, h * 0.25, w * 0.9, h * 0.55, w * 0.5, h * 0.8)
          ..close();
        canvas.drawPath(path, fillPaint);
        break;

      case NeoIconType.coin:
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.4, fillPaint);
        final innerPaint = Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.08;
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.25, innerPaint);
        break;

      case NeoIconType.star:
        final path = Path();
        const numPoints = 5;
        const outerR = 0.45;
        const innerR = 0.20;
        final cx = w * 0.5;
        final cy = h * 0.5;
        for (int i = 0; i < numPoints * 2; i++) {
          final r = (i % 2 == 0) ? w * outerR : w * innerR;
          final angle = (i * math.pi / numPoints) - (math.pi / 2);
          final x = cx + r * math.cos(angle);
          final y = cy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, fillPaint);
        break;

      case NeoIconType.lock:
        // Shackle
        final shacklePath = Path()
          ..moveTo(w * 0.3, h * 0.45)
          ..lineTo(w * 0.3, h * 0.3)
          ..arcToPoint(Offset(w * 0.7, h * 0.3), radius: Radius.circular(w * 0.2))
          ..lineTo(w * 0.7, h * 0.45);
        canvas.drawPath(shacklePath, paint);
        // Body
        final bodyRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.2, h * 0.45, w * 0.6, h * 0.45),
          Radius.circular(w * 0.1),
        );
        canvas.drawRRect(bodyRect, fillPaint);
        break;

      case NeoIconType.undo:
        final path = Path()
          ..moveTo(w * 0.3, h * 0.4)
          ..lineTo(w * 0.15, h * 0.25)
          ..lineTo(w * 0.15, h * 0.55)
          ..lineTo(w * 0.45, h * 0.55);
        canvas.drawPath(path, fillPaint);
        final arcPath = Path()
          ..arcTo(
            Rect.fromCircle(center: Offset(w * 0.55, h * 0.55), radius: w * 0.35),
            math.pi,
            math.pi * 0.8,
            false,
          );
        canvas.drawPath(arcPath, paint);
        break;

      case NeoIconType.hint:
        // Bulb shape
        final bulb = Path()
          ..moveTo(w * 0.35, h * 0.65)
          ..lineTo(w * 0.35, h * 0.55)
          ..cubicTo(w * 0.2, h * 0.4, w * 0.3, h * 0.15, w * 0.5, h * 0.15)
          ..cubicTo(w * 0.7, h * 0.15, w * 0.8, h * 0.4, w * 0.65, h * 0.55)
          ..lineTo(w * 0.65, h * 0.65)
          ..close();
        canvas.drawPath(bulb, fillPaint);
        canvas.drawLine(Offset(w * 0.4, h * 0.75), Offset(w * 0.6, h * 0.75), paint);
        break;

      case NeoIconType.refresh:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.35),
          0.3,
          math.pi * 1.5,
          false,
          paint,
        );
        final arrowPath = Path()
          ..moveTo(w * 0.8, h * 0.3)
          ..lineTo(w * 0.88, h * 0.52)
          ..lineTo(w * 0.65, h * 0.45)
          ..close();
        canvas.drawPath(arrowPath, fillPaint);
        break;

      case NeoIconType.settings:
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.25, paint);
        for (int i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          final x1 = w * 0.5 + (w * 0.32) * math.cos(angle);
          final y1 = h * 0.5 + (h * 0.32) * math.sin(angle);
          final x2 = w * 0.5 + (w * 0.45) * math.cos(angle);
          final y2 = h * 0.5 + (h * 0.45) * math.sin(angle);
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
        }
        break;

      case NeoIconType.trophy:
        final cup = Path()
          ..moveTo(w * 0.25, h * 0.2)
          ..lineTo(w * 0.75, h * 0.2)
          ..lineTo(w * 0.65, h * 0.6)
          ..quadraticBezierTo(w * 0.5, h * 0.75, w * 0.35, h * 0.6)
          ..close();
        canvas.drawPath(cup, fillPaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.7), Offset(w * 0.5, h * 0.85), paint);
        canvas.drawLine(Offset(w * 0.3, h * 0.85), Offset(w * 0.7, h * 0.85), paint);
        break;

      case NeoIconType.stopwatch:
        canvas.drawCircle(Offset(w * 0.5, h * 0.55), w * 0.35, paint);
        canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.2), paint);
        canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.5, h * 0.35), paint);
        canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.65, h * 0.55), paint);
        break;

      case NeoIconType.checkmark:
        final path = Path()
          ..moveTo(w * 0.2, h * 0.5)
          ..lineTo(w * 0.42, h * 0.72)
          ..lineTo(w * 0.8, h * 0.28);
        canvas.drawPath(path, paint);
        break;

      case NeoIconType.gift:
        final box = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.45),
          Radius.circular(w * 0.08),
        );
        canvas.drawRRect(box, fillPaint);
        final lid = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, h * 0.3, w * 0.7, h * 0.12),
          Radius.circular(w * 0.05),
        );
        canvas.drawRRect(lid, fillPaint);
        final ribbonPaint = Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..strokeWidth = w * 0.08;
        canvas.drawLine(Offset(w * 0.5, h * 0.3), Offset(w * 0.5, h * 0.85), ribbonPaint);
        break;

      case NeoIconType.chevronLeft:
        final path = Path()
          ..moveTo(w * 0.65, h * 0.2)
          ..lineTo(w * 0.35, h * 0.5)
          ..lineTo(w * 0.65, h * 0.8);
        canvas.drawPath(path, paint);
        break;

      case NeoIconType.chevronRight:
        final path = Path()
          ..moveTo(w * 0.35, h * 0.2)
          ..lineTo(w * 0.65, h * 0.5)
          ..lineTo(w * 0.35, h * 0.8);
        canvas.drawPath(path, paint);
        break;

      case NeoIconType.user:
        canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.2, fillPaint);
        final body = Path()
          ..moveTo(w * 0.2, h * 0.85)
          ..quadraticBezierTo(w * 0.25, h * 0.6, w * 0.5, h * 0.6)
          ..quadraticBezierTo(w * 0.75, h * 0.6, w * 0.8, h * 0.85)
          ..close();
        canvas.drawPath(body, fillPaint);
        break;
    }
  }

  void _drawArrow(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.5);
    double rotation = 0;
    if (type == NeoIconType.arrowRight) rotation = math.pi * 0.5;
    if (type == NeoIconType.arrowDown) rotation = math.pi;
    if (type == NeoIconType.arrowLeft) rotation = -math.pi * 0.5;
    canvas.rotate(rotation);

    final w = size.width;
    final h = size.height;

    // Arrow pointing UP
    final path = Path()
      ..moveTo(0, -h * 0.38)
      ..lineTo(-w * 0.3, -h * 0.05)
      ..lineTo(-w * 0.12, -h * 0.05)
      ..lineTo(-w * 0.12, h * 0.38)
      ..lineTo(w * 0.12, h * 0.38)
      ..lineTo(w * 0.12, -h * 0.05)
      ..lineTo(w * 0.3, -h * 0.05)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NeoIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
