import 'position.dart';

enum Player {
  /// Bottom player; starts at (8, 4).
  red,

  /// Left player; starts at (4, 0).
  green,

  /// Top player; starts at (0, 4).
  blue,

  /// Right player; starts at (4, 8).
  yellow;

  /// Next player in clockwise order (for 4-player Rush mode).
  Player get nextRush => switch (this) {
    red => green,
    green => blue,
    blue => yellow,
    yellow => red,
  };

  /// The opposing player in 2-player modes.
  Player get opponent => switch (this) {
    red => blue,
    blue => red,
    green => yellow,
    yellow => green,
  };

  Position get startPosition => switch (this) {
    red => const Position(8, 4),
    blue => const Position(0, 4),
    green => const Position(4, 0),
    yellow => const Position(4, 8),
  };

  int get goalRow => switch (this) {
    red => 0,
    blue => Position.boardSize - 1,
    green => 0,
    yellow => 0,
  };

  String get displayName => switch (this) {
    red => 'Red (Player)',
    blue => 'Blue (AI / Opponent)',
    green => 'Green',
    yellow => 'Yellow',
  };
}
