import 'dart:math';

import '../engine/engine.dart';
import 'ai_player.dart';
import 'ai_utils.dart';

/// Negamax with alpha-beta pruning and iterative deepening.
class HardAi implements AiPlayer {
  HardAi(
    this._rng, {
    this.timeBudget = const Duration(milliseconds: 900),
    this.wallWeight = defaultWallWeight,
  });

  final Random _rng;
  final Duration timeBudget;

  final double wallWeight;

  static const double winScore = 1000;
  static const double defaultWallWeight = 0.4;
  static const int baseDepth = 2;
  static const int maxDepth = 3;

  late Stopwatch _clock;
  bool _deadlineEnabled = false;

  @override
  Move chooseMove(GameState state) {
    _clock = Stopwatch()..start();

    final step = bestPawnMove(state, _rng);
    if (state.isGoal(state.currentPlayer, step.to)) return step;

    if (state.variant == GameVariant.rush) {
      return _chooseRushMove(state) ?? step;
    }

    _deadlineEnabled = false;
    var best = _searchRoot(state, baseDepth) ?? step;

    _deadlineEnabled = true;
    for (var depth = baseDepth + 1; depth <= maxDepth; depth++) {
      try {
        best = _searchRoot(state, depth) ?? best;
      } on _Timeout {
        break;
      }
    }
    return best;
  }

  Move? _chooseRushMove(GameState s) {
    final me = s.currentPlayer;
    final moves = _orderedMoves(s);
    if (moves.isEmpty) return null;
    Move? bestMove;
    var bestScore = double.negativeInfinity;
    for (final m in moves) {
      final next = applyMove(s, m);
      if (next.isOver && next.winner == me) return m;
      final score = _evaluateFor(next, me);
      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
      }
    }
    return bestMove;
  }

  double _evaluateFor(GameState s, Player player) {
    final myLen = pathLengthOf(s, player);
    final oppMinLen = [
      for (final opp in s.activePlayers)
        if (opp != player) pathLengthOf(s, opp),
    ].reduce(min);
    return (oppMinLen - myLen) + wallWeight * s.wallsLeftOf(player);
  }

  List<(Move, double)> scoreMoves(GameState state, {int depth = baseDepth}) {
    _clock = Stopwatch()..start();
    _deadlineEnabled = false;
    if (state.variant == GameVariant.rush) {
      final me = state.currentPlayer;
      return [
        for (final m in _orderedMoves(state))
          (m, _evaluateFor(applyMove(state, m), me)),
      ];
    }
    return [
      for (final m in _orderedMoves(state))
        (
          m,
          -_negamax(
            applyMove(state, m),
            depth - 1,
            double.negativeInfinity,
            double.infinity,
          ),
        ),
    ];
  }

  Move? _searchRoot(GameState state, int depth) {
    Move? best;
    var alpha = double.negativeInfinity;
    for (final m in _orderedMoves(state)) {
      final score = -_negamax(
        applyMove(state, m),
        depth - 1,
        double.negativeInfinity,
        -alpha,
      );
      if (score > alpha) {
        alpha = score;
        best = m;
      }
    }
    return best;
  }

  double _negamax(GameState s, int depth, double alpha, double beta) {
    if (_deadlineEnabled && _clock.elapsed > timeBudget) throw const _Timeout();
    if (s.isOver) {
      return -(winScore + depth);
    }
    if (depth == 0) return evaluate(s);

    var a = alpha;
    var best = double.negativeInfinity;
    for (final m in _orderedMoves(s)) {
      final score = -_negamax(applyMove(s, m), depth - 1, -beta, -a);
      if (score > best) best = score;
      if (score > a) a = score;
      if (a >= beta) break;
    }
    return best;
  }

  double evaluate(GameState s) {
    final me = s.currentPlayer;
    if (s.variant == GameVariant.rush) {
      return _evaluateFor(s, me) + 0.5;
    }
    final opp = me.opponent;
    final myLen = pathLengthOf(s, me);
    final oppLen = pathLengthOf(s, opp);
    return (oppLen - myLen) +
        0.5 +
        wallWeight * (s.wallsLeftOf(me) - s.wallsLeftOf(opp));
  }

  List<Move> _orderedMoves(GameState s) {
    final me = s.currentPlayer;
    final pawns = legalPawnMoves(s).toList()
      ..sort((a, b) => _pawnKey(s, a, me).compareTo(_pawnKey(s, b, me)));
    final walls = candidateWalls(s)..shuffle(_rng);
    final gains = {for (final w in walls) w: wallGain(s, w)};
    walls
      ..removeWhere((w) => gains[w]! <= 0)
      ..sort((a, b) => gains[b]!.compareTo(gains[a]!));
    return [
      for (final p in pawns) PawnMove(p),
      for (final w in walls) WallMove(w),
    ];
  }

  static int _pawnKey(GameState s, Position t, Player me) =>
      s.isGoal(me, t) ? -1 : pathLength(s, s.walls, t, me);
}

class _Timeout implements Exception {
  const _Timeout();
}
