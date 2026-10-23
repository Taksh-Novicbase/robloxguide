enum WallOrientation { horizontal, vertical }

/// A 2-cell wall identified by its anchor (center point) on the 8x8 grid of
/// groove intersections.
///
/// * Horizontal at (r, c): runs along the bottom edge of cells (r, c) and
///   (r, c+1), blocking movement between row r and row r+1 in those columns.
/// * Vertical at (r, c): runs along the right edge of cells (r, c) and
///   (r+1, c), blocking movement between column c and column c+1 in those rows.
///
/// Valid anchors are 0..7 for both row and col.
class Wall {
  const Wall(this.row, this.col, this.orientation);

  const Wall.horizontal(this.row, this.col)
      : orientation = WallOrientation.horizontal;

  const Wall.vertical(this.row, this.col)
      : orientation = WallOrientation.vertical;

  final int row;
  final int col;
  final WallOrientation orientation;

  static const int anchorCount = 8;

  bool get isInBounds =>
      row >= 0 && row < anchorCount && col >= 0 && col < anchorCount;

  bool get isHorizontal => orientation == WallOrientation.horizontal;

  /// Whether this wall overlaps or crosses [other].
  bool conflictsWith(Wall other) {
    if (row == other.row && col == other.col) return true; // overlap or cross
    if (orientation != other.orientation) return false;
    if (isHorizontal) {
      return row == other.row && (col - other.col).abs() == 1;
    }
    return col == other.col && (row - other.row).abs() == 1;
  }

  @override
  bool operator ==(Object other) =>
      other is Wall &&
      other.row == row &&
      other.col == col &&
      other.orientation == orientation;

  @override
  int get hashCode => Object.hash(row, col, orientation);

  @override
  String toString() => 'Wall(${isHorizontal ? 'H' : 'V'} $row, $col)';
}
