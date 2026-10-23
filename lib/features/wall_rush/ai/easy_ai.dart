import 'dart:math';

import '../engine/engine.dart';
import 'ai_player.dart';
import 'ai_utils.dart';

/// Random legal moves, biased toward moving forward. Occasionally drops a random wall.
class EasyAi implements AiPlayer {
  EasyAi(this._rng);

  final Random _rng;

  static const wallChance = 0.15;
  static const forwardChance = 0.75;

  @override
  Move chooseMove(GameState state) {
    final me = state.currentPlayer;
    final targets = legalPawnMoves(state).toList();

    // Never miss an immediate win.
    for (final t in targets) {
      if (state.isGoal(me, t)) return PawnMove(t);
    }

    if (state.wallsLeftOf(me) > 0 && _rng.nextDouble() < wallChance) {
      final walls = legalWalls(state);
      if (walls.isNotEmpty) return WallMove(walls[_rng.nextInt(walls.length)]);
    }

    final current = pathLengthOf(state, me);
    final forward = [
      for (final t in targets)
        if (pathLength(state, state.walls, t, me) < current) t,
    ];
    final pool = forward.isNotEmpty && _rng.nextDouble() < forwardChance
        ? forward
        : targets;
    return PawnMove(pool[_rng.nextInt(pool.length)]);
  }
}
