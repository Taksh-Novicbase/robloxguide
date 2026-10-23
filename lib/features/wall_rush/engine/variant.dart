import 'game_state.dart';
import 'position.dart';

/// Wall Rush rule sets.
enum GameVariant {
  /// Race to the opponent's starting row; 10 walls each.
  classic(wallsPerPlayer: GameState.defaultWallsPerPlayer),

  /// Crown Rush: both race to one crown on the middle row; 6 walls each.
  crown(wallsPerPlayer: 6),

  /// Race Mode: both pawns start at the bottom row and race to row 0; 8 walls each.
  race(wallsPerPlayer: 8),

  /// Rush Mode: 4 players race to the center of the board; 5 walls each.
  rush(wallsPerPlayer: 5);

  const GameVariant({required this.wallsPerPlayer});

  final int wallsPerPlayer;

  /// The center cell of the board: all 4 players race here in Rush mode.
  static const Position centerGoal = Position(4, 4);

  /// The middle row: every cell on it is the same distance from both starting cells.
  static const int crownRow = Position.boardSize ~/ 2;

  /// Default starting position for Player.red in Race mode.
  static const Position raceRedStart = Position(8, 3);

  /// Default starting position for Player.blue in Race mode.
  static const Position raceBlueStart = Position(8, 5);

  /// The variant [state] is played in.
  static GameVariant of(GameState state) => state.variant;

  GameState initialState({
    int crownColumn = Position.boardSize ~/ 2,
    Position redStart = raceRedStart,
    Position blueStart = raceBlueStart,
  }) => switch (this) {
    classic => GameState.initial(),
    crown => GameState.initial(
      variant: crown,
      wallsPerPlayer: wallsPerPlayer,
      crown: Position(crownRow, crownColumn),
    ),
    race => GameState.initial(
      variant: race,
      wallsPerPlayer: wallsPerPlayer,
      redPosition: redStart,
      bluePosition: blueStart,
    ),
    rush => GameState.initial(
      variant: rush,
      wallsPerPlayer: wallsPerPlayer,
    ),
  };

  String get displayName => switch (this) {
    classic => 'Classic (10 Walls)',
    crown => 'Crown Rush (6 Walls)',
    race => 'Race Mode (8 Walls)',
    rush => '4-Player Rush (5 Walls)',
  };

  String get description => switch (this) {
    classic =>
      'Traditional 9x9 Quoridor rules. Red races to Row 0, Blue races to Row 8. 10 walls each to construct mazes and block the opponent.',
    crown =>
      'Fast-paced race to the Golden Crown on the center tile (Row 4, Col 4). Both pawns start at equal distance with 6 strategic walls each.',
    race =>
      'Both players start side-by-side at the bottom baseline and sprint to the finish line at Row 0 while erecting barricades.',
    rush =>
      '4-Player free-for-all! Red, Blue, Green, and Yellow pawns advance from all 4 corners toward the single center crown cell.',
  };
}
