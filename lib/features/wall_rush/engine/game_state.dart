import 'player.dart';
import 'position.dart';
import 'variant.dart';
import 'wall.dart';

/// `abandoned`: opponent disconnected
enum GameEndReason { reachedGoal, timeout, resign, abandoned }

/// Immutable snapshot of a Wall Rush game.
class GameState {
  static const int defaultWallsPerPlayer = 10;

  GameState({
    required this.redPosition,
    required this.bluePosition,
    this.greenPosition,
    this.yellowPosition,
    required this.redWallsLeft,
    required this.blueWallsLeft,
    this.greenWallsLeft,
    this.yellowWallsLeft,
    required Set<Wall> walls,
    required this.currentPlayer,
    this.winner,
    this.endReason,
    this.crown,
    this.variant = GameVariant.classic,
  }) : walls = Set.unmodifiable(walls);

  factory GameState.initial({
    GameVariant variant = GameVariant.classic,
    int? wallsPerPlayer,
    Position? redPosition,
    Position? bluePosition,
    Position? greenPosition,
    Position? yellowPosition,
    Position? crown,
  }) {
    final v = crown != null ? GameVariant.crown : variant;
    final walls = wallsPerPlayer ?? v.wallsPerPlayer;
    return GameState(
      redPosition: redPosition ?? Player.red.startPosition,
      bluePosition: bluePosition ?? Player.blue.startPosition,
      greenPosition: greenPosition ??
          (v == GameVariant.rush ? Player.green.startPosition : null),
      yellowPosition: yellowPosition ??
          (v == GameVariant.rush ? Player.yellow.startPosition : null),
      redWallsLeft: walls,
      blueWallsLeft: walls,
      greenWallsLeft: v == GameVariant.rush ? walls : null,
      yellowWallsLeft: v == GameVariant.rush ? walls : null,
      walls: const {},
      currentPlayer: Player.red,
      winner: null,
      endReason: null,
      crown: v == GameVariant.crown ? (crown ?? GameVariant.centerGoal) : null,
      variant: v,
    );
  }

  final Position redPosition;
  final Position bluePosition;
  final Position? greenPosition;
  final Position? yellowPosition;
  final int redWallsLeft;
  final int blueWallsLeft;
  final int? greenWallsLeft;
  final int? yellowWallsLeft;
  final Set<Wall> walls;
  final Player currentPlayer;
  final Player? winner;
  final GameEndReason? endReason;

  /// Crown mode: the cell both players race to (null in classic).
  final Position? crown;

  /// The game variant / rule set.
  final GameVariant variant;

  bool get isOver => winner != null;

  /// Active players in this match (4 in Rush, 2 in classic/crown/race).
  List<Player> get activePlayers => variant == GameVariant.rush
      ? const [Player.red, Player.green, Player.blue, Player.yellow]
      : const [Player.red, Player.blue];

  /// Next player in turn order.
  Player nextPlayerAfter(Player p) =>
      variant == GameVariant.rush ? p.nextRush : p.opponent;

  /// Whether [cell] wins the game for [player].
  bool isGoal(Player player, Position cell) {
    if (variant == GameVariant.rush) {
      return cell == GameVariant.centerGoal;
    }
    if (variant == GameVariant.crown || crown != null) {
      return cell == (crown ?? GameVariant.centerGoal);
    }
    if (variant == GameVariant.race) {
      return cell.row == 0;
    }
    return cell.row == player.goalRow;
  }

  Position positionOf(Player p) => switch (p) {
    Player.red => redPosition,
    Player.blue => bluePosition,
    Player.green => greenPosition ?? Player.green.startPosition,
    Player.yellow => yellowPosition ?? Player.yellow.startPosition,
  };

  int wallsLeftOf(Player p) => switch (p) {
    Player.red => redWallsLeft,
    Player.blue => blueWallsLeft,
    Player.green => greenWallsLeft ?? 0,
    Player.yellow => yellowWallsLeft ?? 0,
  };

  GameState withPosition(Player player, Position to) => switch (player) {
    Player.red => copyWith(redPosition: to),
    Player.blue => copyWith(bluePosition: to),
    Player.green => copyWith(greenPosition: to),
    Player.yellow => copyWith(yellowPosition: to),
  };

  GameState withWallPlaced(Player player, Wall wall) => copyWith(
    walls: {...walls, wall},
    redWallsLeft: player == Player.red ? redWallsLeft - 1 : redWallsLeft,
    blueWallsLeft: player == Player.blue ? blueWallsLeft - 1 : blueWallsLeft,
    greenWallsLeft:
        player == Player.green ? (greenWallsLeft ?? 0) - 1 : greenWallsLeft,
    yellowWallsLeft:
        player == Player.yellow ? (yellowWallsLeft ?? 0) - 1 : yellowWallsLeft,
    currentPlayer: nextPlayerAfter(player),
  );

  GameState copyWith({
    Position? redPosition,
    Position? bluePosition,
    Position? greenPosition,
    Position? yellowPosition,
    int? redWallsLeft,
    int? blueWallsLeft,
    int? greenWallsLeft,
    int? yellowWallsLeft,
    Set<Wall>? walls,
    Player? currentPlayer,
    Player? winner,
    GameEndReason? endReason,
    Position? crown,
    GameVariant? variant,
  }) => GameState(
    redPosition: redPosition ?? this.redPosition,
    bluePosition: bluePosition ?? this.bluePosition,
    greenPosition: greenPosition ?? this.greenPosition,
    yellowPosition: yellowPosition ?? this.yellowPosition,
    redWallsLeft: redWallsLeft ?? this.redWallsLeft,
    blueWallsLeft: blueWallsLeft ?? this.blueWallsLeft,
    greenWallsLeft: greenWallsLeft ?? this.greenWallsLeft,
    yellowWallsLeft: yellowWallsLeft ?? this.yellowWallsLeft,
    walls: walls ?? this.walls,
    currentPlayer: currentPlayer ?? this.currentPlayer,
    winner: winner ?? this.winner,
    endReason: endReason ?? this.endReason,
    crown: crown ?? this.crown,
    variant: variant ?? this.variant,
  );
}
