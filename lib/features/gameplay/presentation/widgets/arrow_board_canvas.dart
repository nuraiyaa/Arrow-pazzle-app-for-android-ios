import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/arrow_direction.dart';
import '../../../../domain/models/arrow_entity.dart';
import '../../../../domain/models/grid_position.dart';
import '../../../../domain/models/puzzle_board.dart';

/// High-Performance Hardware-Accelerated Arrow Board Canvas
class ArrowBoardCanvas extends StatefulWidget {
  final PuzzleBoard board;
  final String? activeHintId;
  final String? collidingArrowId;
  final Function(String arrowId) onArrowTapped;
  final double size;

  const ArrowBoardCanvas({
    super.key,
    required this.board,
    this.activeHintId,
    this.collidingArrowId,
    required this.onArrowTapped,
    this.size = 320,
  });

  @override
  State<ArrowBoardCanvas> createState() => _ArrowBoardCanvasState();
}

class _ArrowBoardCanvasState extends State<ArrowBoardCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant ArrowBoardCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collidingArrowId != oldWidget.collidingArrowId && widget.collidingArrowId != null) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final cellWidth = widget.size / widget.board.width;
    final cellHeight = widget.size / widget.board.height;

    final gridX = (details.localPosition.dx / cellWidth).floor();
    final gridY = (details.localPosition.dy / cellHeight).floor();

    final targetPos = GridPosition(gridX, gridY);
    final arrow = widget.board.getArrowAt(targetPos);
    if (arrow != null) {
      widget.onArrowTapped(arrow.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) => CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _BoardPainter(
            board: widget.board,
            activeHintId: widget.activeHintId,
            collidingArrowId: widget.collidingArrowId,
            shakeProgress: _animController.value,
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final PuzzleBoard board;
  final String? activeHintId;
  final String? collidingArrowId;
  final double shakeProgress;

  _BoardPainter({
    required this.board,
    this.activeHintId,
    this.collidingArrowId,
    required this.shakeProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / board.width;
    final cellH = size.height / board.height;
    final padding = cellW * 0.08;

    // 1. Draw Board Background and Border
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );

    final bgPaint = Paint()
      ..color = AppColors.surfaceCard
      ..style = PaintingStyle.fill;
    canvas.drawRRect(boardRect, bgPaint);

    final borderPaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(boardRect, borderPaint);

    // 2. Draw Subtle Grid Matrix Slots
    final slotPaint = Paint()
      ..color = AppColors.surfaceCardElevated.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int y = 0; y < board.height; y++) {
      for (int x = 0; x < board.width; x++) {
        final slotRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x * cellW + padding,
            y * cellH + padding,
            cellW - padding * 2,
            cellH - padding * 2,
          ),
          Radius.circular(cellW * 0.22),
        );
        canvas.drawRRect(slotRect, slotPaint);
      }
    }

    // 3. Draw Obstacles
    final obstaclePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    for (final obs in board.obstacles) {
      final obsRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          obs.x * cellW + padding,
          obs.y * cellH + padding,
          cellW - padding * 2,
          cellH - padding * 2,
        ),
        Radius.circular(cellW * 0.22),
      );
      canvas.drawRRect(obsRect, obstaclePaint);
    }

    // 4. Draw Active Arrows
    for (final arrow in board.activeArrows) {
      _drawArrowTile(canvas, arrow, cellW, cellH, padding);
    }
  }

  void _drawArrowTile(
    Canvas canvas,
    ArrowEntity arrow,
    double cellW,
    double cellH,
    double padding,
  ) {
    final isHinted = arrow.id == activeHintId;
    final isColliding = arrow.id == collidingArrowId;

    double offsetX = arrow.position.x * cellW + padding;
    double offsetY = arrow.position.y * cellH + padding;

    // Apply collision shake offset if colliding
    if (isColliding && shakeProgress < 1.0) {
      final shake = math.sin(shakeProgress * math.pi * 4) * 5.0 * (1.0 - shakeProgress);
      offsetX += shake;
    }

    final tileW = cellW - padding * 2;
    final tileH = cellH - padding * 2;
    final tileRadius = Radius.circular(tileW * 0.24);

    final tileRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offsetX, offsetY, tileW, tileH),
      tileRadius,
    );

    // Draw Glow for Hinted Arrow
    if (isHinted) {
      final glowPaint = Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(tileRect, glowPaint);
    }

    // Draw Tile Body
    final tilePaint = Paint()
      ..color = isHinted
          ? AppColors.accentGold.withValues(alpha: 0.25)
          : isColliding
              ? AppColors.accentWarning.withValues(alpha: 0.25)
              : AppColors.surfaceCardElevated
      ..style = PaintingStyle.fill;
    canvas.drawRRect(tileRect, tilePaint);

    // Draw Tile Border
    final borderPaint = Paint()
      ..color = isHinted
          ? AppColors.accentGold
          : isColliding
              ? AppColors.accentWarning
              : AppColors.surfaceBorderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHinted || isColliding ? 2.0 : 1.0;
    canvas.drawRRect(tileRect, borderPaint);

    // Draw Direction Arrow Vector
    final arrowColor = isHinted
        ? AppColors.accentGold
        : isColliding
            ? AppColors.accentWarning
            : AppColors.textPrimary;

    _drawArrowVector(
      canvas,
      Offset(offsetX + tileW * 0.5, offsetY + tileH * 0.5),
      tileW * 0.55,
      arrow.direction,
      arrowColor,
    );
  }

  void _drawArrowVector(
    Canvas canvas,
    Offset center,
    double size,
    ArrowDirection dir,
    Color color,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(dir.angleRadians + math.pi / 2); // Default drawn pointing UP

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size;
    final h = size;

    final path = Path()
      ..moveTo(0, -h * 0.45)
      ..lineTo(-w * 0.36, -h * 0.05)
      ..lineTo(-w * 0.14, -h * 0.05)
      ..lineTo(-w * 0.14, h * 0.45)
      ..lineTo(w * 0.14, h * 0.45)
      ..lineTo(w * 0.14, -h * 0.05)
      ..lineTo(w * 0.36, -h * 0.05)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return oldDelegate.board != board ||
        oldDelegate.activeHintId != activeHintId ||
        oldDelegate.collidingArrowId != collidingArrowId ||
        oldDelegate.shakeProgress != shakeProgress;
  }
}
