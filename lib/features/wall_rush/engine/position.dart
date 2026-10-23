/// A cell on the 9x9 Wall Rush board.
///
/// Row 0 is the top edge (Blue's starting row, Red's goal row).
/// Row 8 is the bottom edge (Red's starting row, Blue's goal row).
/// Column 0 is the left edge, Column 8 is the right edge.
class Position {
  const Position(this.row, this.col);

  final int row;
  final int col;

  static const int boardSize = 9;

  bool get isOnBoard =>
      row >= 0 && row < boardSize && col >= 0 && col < boardSize;

  Position operator +(Direction d) => Position(row + d.dRow, col + d.dCol);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row * 31 + col;

  @override
  String toString() => 'Position($row, $col)';
}

/// Orthogonal movement directions.
enum Direction {
  up(-1, 0),
  down(1, 0),
  left(0, -1),
  right(0, 1);

  const Direction(this.dRow, this.dCol);

  final int dRow;
  final int dCol;

  /// The two directions perpendicular to this direction.
  List<Direction> get perpendicular => (this == up || this == down)
      ? const [Direction.left, Direction.right]
      : const [Direction.up, Direction.down];
}
