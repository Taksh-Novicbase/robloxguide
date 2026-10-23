import 'position.dart';
import 'wall.dart';

/// A single turn action in Wall Rush.
sealed class Move {
  const Move();
}

class PawnMove extends Move {
  const PawnMove(this.to);

  final Position to;

  @override
  bool operator ==(Object other) => other is PawnMove && other.to == to;

  @override
  int get hashCode => to.hashCode;

  @override
  String toString() => 'PawnMove($to)';
}

class WallMove extends Move {
  const WallMove(this.wall);

  final Wall wall;

  @override
  bool operator ==(Object other) => other is WallMove && other.wall == wall;

  @override
  int get hashCode => wall.hashCode;

  @override
  String toString() => 'WallMove($wall)';
}

class IllegalMoveException implements Exception {
  const IllegalMoveException(this.message);

  final String message;

  @override
  String toString() => 'IllegalMoveException: $message';
}
