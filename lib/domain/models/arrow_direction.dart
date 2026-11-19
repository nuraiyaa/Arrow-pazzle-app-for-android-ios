import 'dart:math' as math;

/// Cardinal directions for puzzle arrows
enum ArrowDirection {
  up(0, -1, -math.pi / 2),
  down(0, 1, math.pi / 2),
  left(-1, 0, math.pi),
  right(1, 0, 0);

  final int dx;
  final int dy;
  final double angleRadians;

  const ArrowDirection(this.dx, this.dy, this.angleRadians);

  /// Returns the opposite direction
  ArrowDirection get opposite {
    switch (this) {
      case ArrowDirection.up:
        return ArrowDirection.down;
      case ArrowDirection.down:
        return ArrowDirection.up;
      case ArrowDirection.left:
        return ArrowDirection.right;
      case ArrowDirection.right:
        return ArrowDirection.left;
    }
  }
}
