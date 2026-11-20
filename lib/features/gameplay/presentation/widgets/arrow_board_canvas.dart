import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/arrow_direction.dart';
import '../../../../domain/models/arrow_entity.dart';
import '../../../../domain/models/puzzle_board.dart';
import '../../../../domain/models/skin_model.dart';

/// Active escape animation metadata
class _ActiveEscape {
  final ArrowEntity arrow;
  final AnimationController controller;
  final Animation<double> slideAnimation;
  final Animation<double> opacityAnimation;

  _ActiveEscape({
    required this.arrow,
    required this.controller,
    required this.slideAnimation,
    required this.opacityAnimation,
  });
}

/// Active collision shake animation metadata
class _ActiveCollision {
  final ArrowEntity arrow;
  final AnimationController controller;

  _ActiveCollision({
    required this.arrow,
    required this.controller,
  });
}

/// High-Performance Light-Mode Polyline Arrow Canvas with Fluid Escape & Bump Animations
class ArrowBoardCanvas extends StatefulWidget {
  final PuzzleBoard board;
  final ArrowSkin? skin;
  final String? activeHintId;
  final String? collidingArrowId;
  final Function(String arrowId) onArrowTapped;
  final double size;

  const ArrowBoardCanvas({
    super.key,
    required this.board,
    this.skin,
    this.activeHintId,
    this.collidingArrowId,
    required this.onArrowTapped,
    this.size = 340,
  });

  @override
  State<ArrowBoardCanvas> createState() => _ArrowBoardCanvasState();
}

class _ArrowBoardCanvasState extends State<ArrowBoardCanvas> with TickerProviderStateMixin {
  final Map<String, _ActiveEscape> _activeEscapes = {};
  final Map<String, _ActiveCollision> _activeCollisions = {};
  Set<String> _previouslyKnownArrowIds = {};

  @override
  void initState() {
    super.initState();
    _previouslyKnownArrowIds = widget.board.activeArrows.map((a) => a.id).toSet();
  }

  @override
  void didUpdateWidget(covariant ArrowBoardCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect arrows that were cleared/escaped to trigger the smooth escape flight
    final currentIds = widget.board.activeArrows.map((a) => a.id).toSet();
    final missingIds = _previouslyKnownArrowIds.difference(currentIds);

    for (final escapedId in missingIds) {
      final oldArrow = oldWidget.board.getArrowById(escapedId);
      if (oldArrow != null && !_activeEscapes.containsKey(escapedId)) {
        _triggerEscapeAnimation(oldArrow);
      }
    }
    _previouslyKnownArrowIds = currentIds;

    // Detect collision to trigger bump & shake recoil
    if (widget.collidingArrowId != null &&
        widget.collidingArrowId != oldWidget.collidingArrowId) {
      final arrow = widget.board.getArrowById(widget.collidingArrowId!);
      if (arrow != null) {
        _triggerCollisionAnimation(arrow);
      }
    }
  }

  void _triggerEscapeAnimation(ArrowEntity arrow) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    final slideAnim = Tween<double>(begin: 0.0, end: widget.size * 1.15).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInCubic),
    );

    final opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    final escape = _ActiveEscape(
      arrow: arrow,
      controller: controller,
      slideAnimation: slideAnim,
      opacityAnimation: opacityAnim,
    );

    setState(() {
      _activeEscapes[arrow.id] = escape;
    });

    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _activeEscapes.remove(arrow.id);
        });
      }
      controller.dispose();
    });
  }

  void _triggerCollisionAnimation(ArrowEntity arrow) {
    // If already colliding, reset
    _activeCollisions[arrow.id]?.controller.dispose();

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    final collision = _ActiveCollision(
      arrow: arrow,
      controller: controller,
    );

    setState(() {
      _activeCollisions[arrow.id] = collision;
    });

    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _activeCollisions.remove(arrow.id);
        });
      }
      controller.dispose();
    });
  }

  @override
  void dispose() {
    for (final escape in _activeEscapes.values) {
      escape.controller.dispose();
    }
    for (final collision in _activeCollisions.values) {
      collision.controller.dispose();
    }
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final cellW = widget.size / widget.board.width;
    final cellH = widget.size / widget.board.height;
    final tapPos = details.localPosition;

    // Check hit test across all active arrows' line segments
    ArrowEntity? tappedArrow;
    double closestDistance = double.infinity;
    final maxTouchRadius = cellW * 0.65;

    for (final arrow in widget.board.activeArrows) {
      // Don't register taps on arrows currently flying off
      if (_activeEscapes.containsKey(arrow.id)) continue;

      final points = arrow.effectivePoints;
      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final center = Offset(p.x * cellW + cellW / 2, p.y * cellH + cellH / 2);
        final dist = (tapPos - center).distance;
        if (dist < closestDistance && dist <= maxTouchRadius) {
          closestDistance = dist;
          tappedArrow = arrow;
        }

        // Also check distance to segment lines
        if (i < points.length - 1) {
          final nextP = points[i + 1];
          final nextCenter = Offset(nextP.x * cellW + cellW / 2, nextP.y * cellH + cellH / 2);
          final segDist = _distanceToSegment(tapPos, center, nextCenter);
          if (segDist < closestDistance && segDist <= maxTouchRadius) {
            closestDistance = segDist;
            tappedArrow = arrow;
          }
        }
      }
    }

    if (tappedArrow != null) {
      widget.onArrowTapped(tappedArrow.id);
    }
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final abLenSq = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abLenSq == 0) return (p - a).distance;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / abLenSq).clamp(0.0, 1.0);
    final projection = a + Offset(ab.dx * t, ab.dy * t);
    return (p - projection).distance;
  }

  @override
  Widget build(BuildContext context) {
    // Collect all active animation listenables
    final List<Listenable> listenables = [
      ..._activeEscapes.values.map((e) => e.controller),
      ..._activeCollisions.values.map((c) => c.controller),
    ];

    Widget canvasWidget = CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _PolylineBoardPainter(
        board: widget.board,
        skin: widget.skin ?? ArrowSkin.allSkins.first,
        activeHintId: widget.activeHintId,
        activeEscapes: _activeEscapes,
        activeCollisions: _activeCollisions,
      ),
    );

    if (listenables.isNotEmpty) {
      canvasWidget = AnimatedBuilder(
        animation: Listenable.merge(listenables),
        builder: (context, _) => canvasWidget,
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.boardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          child: canvasWidget,
        ),
      ),
    );
  }
}

class _PolylineBoardPainter extends CustomPainter {
  final PuzzleBoard board;
  final ArrowSkin skin;
  final String? activeHintId;
  final Map<String, _ActiveEscape> activeEscapes;
  final Map<String, _ActiveCollision> activeCollisions;

  _PolylineBoardPainter({
    required this.board,
    required this.skin,
    this.activeHintId,
    required this.activeEscapes,
    required this.activeCollisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / board.width;
    final cellH = size.height / board.height;

    // 1. Draw Subtle Light Dotted Grid Matrix (matching reference game)
    final dotPaint = Paint()
      ..color = AppColors.boardGridDot
      ..style = PaintingStyle.fill;

    for (int y = 0; y < board.height; y++) {
      for (int x = 0; x < board.width; x++) {
        final cx = x * cellW + cellW / 2;
        final cy = y * cellH + cellH / 2;
        canvas.drawCircle(Offset(cx, cy), 2.2, dotPaint);
      }
    }

    // 2. Draw Obstacles (Immovable rocks / blockers)
    final obsPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;
    final obsBorder = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final obs in board.obstacles) {
      final cx = obs.x * cellW + cellW / 2;
      final cy = obs.y * cellH + cellH / 2;
      final obsRect = Rect.fromCenter(center: Offset(cx, cy), width: cellW * 0.6, height: cellH * 0.6);
      final rrect = RRect.fromRectAndRadius(obsRect, Radius.circular(cellW * 0.18));
      canvas.drawRRect(rrect, obsPaint);
      canvas.drawRRect(rrect, obsBorder);
    }

    // 3. Draw Active Arrows
    for (final arrow in board.activeArrows) {
      if (activeEscapes.containsKey(arrow.id)) continue; // Handled by escaping layer
      _drawArrow(canvas, arrow, cellW, cellH);
    }

    // 4. Draw Escaping Arrows (Smooth Slide Off Canvas)
    for (final escape in activeEscapes.values) {
      _drawEscapingArrow(canvas, escape, cellW, cellH);
    }
  }

  void _drawArrow(Canvas canvas, ArrowEntity arrow, double cellW, double cellH) {
    final isHinted = arrow.id == activeHintId;
    final collision = activeCollisions[arrow.id];

    Offset translationOffset = Offset.zero;
    Color strokeColor = skin.primaryColor;

    if (skin.id == 'classic_obsidian') {
      strokeColor = AppColors.arrowDefaultStroke; // Crisp dark slate from screenshot
    }

    if (isHinted) {
      strokeColor = AppColors.accentGold;
    } else if (collision != null) {
      final progress = collision.controller.value;
      // Bump forward then recoil with red flash
      final bumpDistance = cellW * 0.22;
      final bump = math.sin(progress * math.pi) * bumpDistance;
      final shake = math.sin(progress * math.pi * 6) * 3.0 * (1.0 - progress);

      translationOffset = Offset(
        arrow.direction.dx * bump + (arrow.direction.dx == 0 ? shake : 0),
        arrow.direction.dy * bump + (arrow.direction.dy == 0 ? shake : 0),
      );
      strokeColor = Color.lerp(AppColors.accentWarning, strokeColor, progress)!;
    }

    _renderPolylineArrow(
      canvas: canvas,
      arrow: arrow,
      cellW: cellW,
      cellH: cellH,
      color: strokeColor,
      translation: translationOffset,
      opacity: 1.0,
      isHinted: isHinted,
    );
  }

  void _drawEscapingArrow(Canvas canvas, _ActiveEscape escape, double cellW, double cellH) {
    final arrow = escape.arrow;
    final slideDist = escape.slideAnimation.value;
    final opacity = escape.opacityAnimation.value;

    final translation = Offset(
      arrow.direction.dx * slideDist,
      arrow.direction.dy * slideDist,
    );

    Color strokeColor = skin.primaryColor;
    if (skin.id == 'classic_obsidian') {
      strokeColor = AppColors.arrowDefaultStroke;
    }

    _renderPolylineArrow(
      canvas: canvas,
      arrow: arrow,
      cellW: cellW,
      cellH: cellH,
      color: strokeColor,
      translation: translation,
      opacity: opacity,
      isHinted: false,
    );
  }

  void _renderPolylineArrow({
    required Canvas canvas,
    required ArrowEntity arrow,
    required double cellW,
    required double cellH,
    required Color color,
    required Offset translation,
    required double opacity,
    required bool isHinted,
  }) {
    final points = arrow.effectivePoints;
    if (points.isEmpty) return;

    final strokeWidth = (cellW * 0.16).clamp(4.0, 7.5);
    final effectiveColor = color.withValues(alpha: opacity);

    final linePaint = Paint()
      ..color = effectiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final pt = Offset(p.x * cellW + cellW / 2, p.y * cellH + cellH / 2) + translation;
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    // Optional hint glow
    if (isHinted) {
      final glowPaint = Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.5 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path, glowPaint);
    }

    // Draw the continuous polyline body
    canvas.drawPath(path, linePaint);

    // Draw arrowhead at the head point
    final headPoint = points.last;
    final headCenter = Offset(
      headPoint.x * cellW + cellW / 2,
      headPoint.y * cellH + cellH / 2,
    ) + translation;

    _drawArrowHead(
      canvas: canvas,
      center: headCenter,
      direction: arrow.direction,
      color: effectiveColor,
      size: strokeWidth * 2.4,
      strokeWidth: strokeWidth,
    );
  }

  void _drawArrowHead({
    required Canvas canvas,
    required Offset center,
    required ArrowDirection direction,
    required Color color,
    required double size,
    required double strokeWidth,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(direction.angleRadians);

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final wingLen = size * 0.85;
    final wingAngle = math.pi * 0.76;

    final path = Path();
    // Tip is at Offset(size * 0.45, 0)
    final tip = Offset(size * 0.45, 0);
    final leftWing = tip + Offset(math.cos(wingAngle) * wingLen, math.sin(wingAngle) * wingLen);
    final rightWing = tip + Offset(math.cos(-wingAngle) * wingLen, math.sin(-wingAngle) * wingLen);

    path.moveTo(leftWing.dx, leftWing.dy);
    path.lineTo(tip.dx, tip.dy);
    path.lineTo(rightWing.dx, rightWing.dy);

    canvas.drawPath(path, headPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PolylineBoardPainter oldDelegate) {
    return true; // Continuously animates during flight/recoil
  }
}
