import 'game_state.dart';
import 'move.dart';
import 'pathfinding.dart';
import 'player.dart';
import 'position.dart';
import 'wall.dart';

/// Cells the current player's pawn may move to, including straight and diagonal jumps.
Set<Position> legalPawnMoves(GameState state) {
  final me = state.positionOf(state.currentPlayer);
  final occupied = {
    for (final p in state.activePlayers)
      if (p != state.currentPlayer) state.positionOf(p),
  };
  final walls = state.walls;
  final result = <Position>{};

  for (final dir in Direction.values) {
    final next = me + dir;
    if (!next.isOnBoard || isStepBlocked(walls, me, next)) continue;
    if (!occupied.contains(next)) {
      result.add(next);
      continue;
    }
    // Opponent is adjacent: try a straight jump.
    final jump = next + dir;
    if (jump.isOnBoard &&
        !occupied.contains(jump) &&
        !isStepBlocked(walls, next, jump)) {
      result.add(jump);
      continue;
    }
    // Straight jump blocked by wall, board edge, or pawn: diagonal options.
    for (final side in dir.perpendicular) {
      final diag = next + side;
      if (diag.isOnBoard &&
          !occupied.contains(diag) &&
          !isStepBlocked(walls, next, diag)) {
        result.add(diag);
      }
    }
  }
  return result;
}

/// Why a wall cannot be placed, or null if it is legal.
String? wallIllegalReason(GameState state, Wall wall) {
  if (state.isOver) return 'Game is already over';
  if (!wall.isInBounds) return 'Wall is off the board';
  if (state.wallsLeftOf(state.currentPlayer) <= 0) return 'No walls left';
  if (state.walls.any(wall.conflictsWith)) {
    return 'Wall overlaps or intersects another wall';
  }
  final walls = {...state.walls, wall};
  for (final p in state.activePlayers) {
    if (goalDistance(state, p, walls: walls) == null) {
      return 'Golden Rule Violation: Wall would completely trap a player from reaching their goal!';
    }
  }
  return null;
}

bool isWallLegal(GameState state, Wall wall) =>
    wallIllegalReason(state, wall) == null;

/// Every legal wall placement for the current player.
List<Wall> legalWalls(GameState state) {
  if (state.isOver || state.wallsLeftOf(state.currentPlayer) <= 0) {
    return const [];
  }
  return [
    for (var r = 0; r < Wall.anchorCount; r++)
      for (var c = 0; c < Wall.anchorCount; c++)
        for (final o in WallOrientation.values)
          if (isWallLegal(state, Wall(r, c, o))) Wall(r, c, o),
  ];
}

/// Every legal move for the current player.
List<Move> legalMoves(GameState state) {
  if (state.isOver) return const [];
  return [
    for (final p in legalPawnMoves(state)) PawnMove(p),
    for (final w in legalWalls(state)) WallMove(w),
  ];
}

/// Applies [move] for the current player. Throws [IllegalMoveException]
/// if the move is not legal.
GameState applyMove(GameState state, Move move) {
  if (state.isOver) throw const IllegalMoveException('Game is over');
  final player = state.currentPlayer;

  switch (move) {
    case PawnMove(:final to):
      if (!legalPawnMoves(state).contains(to)) {
        throw IllegalMoveException('Illegal pawn move to $to');
      }
      final moved = state.withPosition(player, to);
      if (state.isGoal(player, to)) {
        return moved.copyWith(
          winner: player,
          endReason: GameEndReason.reachedGoal,
        );
      }
      return moved.copyWith(currentPlayer: state.nextPlayerAfter(player));

    case WallMove(:final wall):
      final reason = wallIllegalReason(state, wall);
      if (reason != null) throw IllegalMoveException(reason);
      return state.withWallPlaced(player, wall);
  }
}

/// Resigns match.
GameState resign(GameState state, Player player) => state.isOver
    ? state
    : state.copyWith(
        winner: state.activePlayers.firstWhere((p) => p != player),
        endReason: GameEndReason.resign,
      );

/// Timeout match.
GameState timeout(GameState state, Player player) => state.isOver
    ? state
    : state.copyWith(
        winner: state.activePlayers.firstWhere((p) => p != player),
        endReason: GameEndReason.timeout,
      );
