/// Represents an integer (x, y) coordinate on the puzzle grid
class GridPosition {
  final int x;
  final int y;

  const GridPosition(this.x, this.y);

  GridPosition translate(int dx, int dy) {
    return GridPosition(x + dx, y + dy);
  }

  bool isWithinBounds(int width, int height) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x, $y)';
}
