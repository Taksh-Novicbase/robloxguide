import 'dart:math';

import '../engine/engine.dart';

/// Shortest path length from [from] to [player]'s goal in [s].
int pathLength(GameState s, Set<Wall> walls, Position from, Player player) =>
    goalDistance(s, player, walls: walls, from: from)!;

int pathLengthOf(GameState s, Player p) => goalDistance(s, p)!;

/// Legal walls touching either player's shortest path.
List<Wall> candidateWalls(GameState s) {
  if (s.isOver || s.wallsLeftOf(s.currentPlayer) <= 0) return [];
  final anchors = <Wall>{};
  for (final p in s.activePlayers) {
    final path = goalPath(s, p);
    if (path == null) continue;
    for (final cell in path) {
      for (var r = cell.row - 1; r <= cell.row; r++) {
        for (var c = cell.col - 1; c <= cell.col; c++) {
          for (final o in WallOrientation.values) {
            final w = Wall(r, c, o);
            if (w.isInBounds) anchors.add(w);
          }
        }
      }
    }
  }
  return [
    for (final w in anchors)
      if (isWallLegal(s, w)) w,
  ];
}

/// The pawn move that most shortens the current player's path (wins first).
PawnMove bestPawnMove(GameState s, Random rng) {
  final me = s.currentPlayer;
  final targets = legalPawnMoves(s).toList()..shuffle(rng);
  PawnMove? best;
  var bestLen = 1 << 30;
  for (final t in targets) {
    final len = s.isGoal(me, t) ? -1 : pathLength(s, s.walls, t, me);
    if (len < bestLen) {
      bestLen = len;
      best = PawnMove(t);
    }
  }
  return best!;
}

/// Path-length change caused by adding [wall] for both players.
int wallGain(GameState s, Wall wall) {
  final me = s.currentPlayer;
  final opponents = s.activePlayers.where((p) => p != me);
  final walls = {...s.walls, wall};
  final myDelta =
      pathLength(s, walls, s.positionOf(me), me) - pathLengthOf(s, me);
  var maxOppDelta = 0;
  for (final opp in opponents) {
    final oppDelta =
        pathLength(s, walls, s.positionOf(opp), opp) - pathLengthOf(s, opp);
    if (oppDelta > maxOppDelta) {
      maxOppDelta = oppDelta;
    }
  }
  return maxOppDelta - myDelta;
}
