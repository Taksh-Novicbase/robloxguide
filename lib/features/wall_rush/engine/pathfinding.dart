import 'dart:collection';

import 'game_state.dart';
import 'player.dart';
import 'position.dart';
import 'wall.dart';

/// Whether a wall in [walls] blocks a single orthogonal step from [from]
/// to the adjacent cell [to].
bool isStepBlocked(Set<Wall> walls, Position from, Position to) {
  if (from.col == to.col) {
    final top = from.row < to.row ? from.row : to.row;
    final c = from.col;
    return walls.contains(Wall.horizontal(top, c)) ||
        walls.contains(Wall.horizontal(top, c - 1));
  }
  final left = from.col < to.col ? from.col : to.col;
  final r = from.row;
  return walls.contains(Wall.vertical(r, left)) ||
      walls.contains(Wall.vertical(r - 1, left));
}

/// BFS shortest path length (in steps, ignoring pawns) from [from] to any
/// cell on [goalRow]. Returns null if the goal row is unreachable.
int? shortestPathLength(Set<Wall> walls, Position from, int goalRow) =>
    shortestPathLengthTo(walls, from, (p) => p.row == goalRow);

bool hasPathToRow(Set<Wall> walls, Position from, int goalRow) =>
    shortestPathLength(walls, from, goalRow) != null;

/// BFS shortest path (cells, starting with [from] and ending on [goalRow]),
/// ignoring pawns. Returns null if the goal row is unreachable.
List<Position>? shortestPath(Set<Wall> walls, Position from, int goalRow) =>
    shortestPathTo(walls, from, (p) => p.row == goalRow);

/// BFS shortest path length (steps, ignoring pawns) from [from] to the
/// nearest cell where [isGoal] holds. Null if no such cell is reachable.
int? shortestPathLengthTo(
  Set<Wall> walls,
  Position from,
  bool Function(Position) isGoal,
) {
  if (isGoal(from)) return 0;
  final dist = <Position, int>{from: 0};
  final queue = Queue<Position>()..add(from);
  while (queue.isNotEmpty) {
    final cur = queue.removeFirst();
    final d = dist[cur]!;
    for (final dir in Direction.values) {
      final next = cur + dir;
      if (!next.isOnBoard || dist.containsKey(next)) continue;
      if (isStepBlocked(walls, cur, next)) continue;
      if (isGoal(next)) return d + 1;
      dist[next] = d + 1;
      queue.add(next);
    }
  }
  return null;
}

/// BFS shortest path (cells from [from] to the nearest cell where [isGoal]
/// holds), ignoring pawns. Null if no such cell is reachable.
List<Position>? shortestPathTo(
  Set<Wall> walls,
  Position from,
  bool Function(Position) isGoal,
) {
  if (isGoal(from)) return [from];
  final parent = <Position, Position?>{from: null};
  final queue = Queue<Position>()..add(from);
  while (queue.isNotEmpty) {
    final cur = queue.removeFirst();
    for (final dir in Direction.values) {
      final next = cur + dir;
      if (!next.isOnBoard || parent.containsKey(next)) continue;
      if (isStepBlocked(walls, cur, next)) continue;
      parent[next] = cur;
      if (isGoal(next)) {
        final path = <Position>[next];
        Position? p = cur;
        while (p != null) {
          path.add(p);
          p = parent[p];
        }
        return path.reversed.toList();
      }
      queue.add(next);
    }
  }
  return null;
}

/// Shortest path length for [player] to their goal in [state] (the crown
/// in Crown mode), over [walls] (default: the state's) and from [from]
/// (default: the player's pawn). Null if unreachable.
int? goalDistance(
  GameState state,
  Player player, {
  Set<Wall>? walls,
  Position? from,
}) =>
    shortestPathLengthTo(
      walls ?? state.walls,
      from ?? state.positionOf(player),
      (p) => state.isGoal(player, p),
    );

/// Like [goalDistance], but returns the path itself.
List<Position>? goalPath(
  GameState state,
  Player player, {
  Set<Wall>? walls,
  Position? from,
}) =>
    shortestPathTo(
      walls ?? state.walls,
      from ?? state.positionOf(player),
      (p) => state.isGoal(player, p),
    );
