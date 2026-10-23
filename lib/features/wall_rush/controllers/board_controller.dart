import 'dart:async';
import 'package:flutter/foundation.dart';

import '../ai/ai.dart';
import '../engine/engine.dart';

enum PlayMode { movePawn, placeWall }

class BoardController extends ChangeNotifier {
  BoardController({
    GameVariant variant = GameVariant.classic,
    Difficulty difficulty = Difficulty.medium,
    bool vsAi = true,
  })  : _variant = variant,
        _difficulty = difficulty,
        _vsAi = vsAi {
    _state = _variant.initialState();
    _history.add(_state);
  }

  GameVariant _variant;
  Difficulty _difficulty;
  bool _vsAi;
  final Player _humanPlayer = Player.red;

  late GameState _state;
  final List<GameState> _history = [];
  bool _isAiThinking = false;
  String? _statusMessage;
  PlayMode _playMode = PlayMode.movePawn;
  WallOrientation _wallOrientation = WallOrientation.horizontal;
  Wall? _previewWall;
  bool _showPathOverlay = false;
  AiAdvice? _lastAdvice;

  // Getters
  GameState get state => _state;
  GameVariant get variant => _variant;
  Difficulty get difficulty => _difficulty;
  bool get vsAi => _vsAi;
  Player get humanPlayer => _humanPlayer;
  bool get isAiThinking => _isAiThinking;
  String? get statusMessage => _statusMessage;
  PlayMode get playMode => _playMode;
  WallOrientation get wallOrientation => _wallOrientation;
  Wall? get previewWall => _previewWall;
  bool get showPathOverlay => _showPathOverlay;
  AiAdvice? get lastAdvice => _lastAdvice;
  bool get canUndo => _history.length > 1 && !_isAiThinking;

  bool get isHumanTurn =>
      !_state.isOver && (!_vsAi || _state.currentPlayer == _humanPlayer);

  Set<Position> get legalMoves =>
      isHumanTurn && _playMode == PlayMode.movePawn
          ? legalPawnMoves(_state)
          : const {};

  bool get canPlaceWall =>
      isHumanTurn && _state.wallsLeftOf(_state.currentPlayer) > 0;

  String? get previewWallError =>
      _previewWall != null ? wallIllegalReason(_state, _previewWall!) : null;

  bool get isPreviewWallLegal =>
      _previewWall != null && isWallLegal(_state, _previewWall!);

  List<Position>? get myShortestPath =>
      goalPath(_state, _state.currentPlayer);

  List<Position>? get opponentShortestPath {
    final opp = _state.currentPlayer.opponent;
    return goalPath(_state, opp);
  }

  void startNewGame({
    GameVariant? variant,
    Difficulty? difficulty,
    bool? vsAi,
  }) {
    if (variant != null) _variant = variant;
    if (difficulty != null) _difficulty = difficulty;
    if (vsAi != null) _vsAi = vsAi;

    _state = _variant.initialState();
    _history.clear();
    _history.add(_state);
    _isAiThinking = false;
    _statusMessage = null;
    _lastAdvice = null;
    _previewWall = null;
    _playMode = PlayMode.movePawn;
    notifyListeners();
  }

  void setDifficulty(Difficulty diff) {
    _difficulty = diff;
    notifyListeners();
  }

  void setVsAi(bool value) {
    _vsAi = value;
    notifyListeners();
  }

  void setPlayMode(PlayMode mode) {
    _playMode = mode;
    if (mode == PlayMode.movePawn) {
      _previewWall = null;
    } else if (_previewWall == null && canPlaceWall) {
      // Default initial preview anchor in the center of the grooves (3, 3)
      _previewWall = Wall(3, 3, _wallOrientation);
    }
    notifyListeners();
  }

  void selectWallMode(WallOrientation orientation) {
    _wallOrientation = orientation;
    _playMode = PlayMode.placeWall;
    if (_previewWall != null) {
      _previewWall = Wall(_previewWall!.row, _previewWall!.col, orientation);
    } else if (canPlaceWall) {
      _previewWall = Wall(3, 3, orientation);
    }
    notifyListeners();
  }

  void toggleWallOrientation() {
    _wallOrientation = _wallOrientation == WallOrientation.horizontal
        ? WallOrientation.vertical
        : WallOrientation.horizontal;
    if (_previewWall != null) {
      _previewWall = Wall(_previewWall!.row, _previewWall!.col, _wallOrientation);
    }
    notifyListeners();
  }

  void setPreviewWall(Wall wall) {
    _previewWall = wall;
    _wallOrientation = wall.orientation;
    _playMode = PlayMode.placeWall;
    notifyListeners();
  }

  void clearPreviewWall() {
    _previewWall = null;
    _playMode = PlayMode.movePawn;
    notifyListeners();
  }

  void rotatePreviewWall() {
    if (_previewWall == null) return;
    final nextOrientation = _previewWall!.isHorizontal
        ? WallOrientation.vertical
        : WallOrientation.horizontal;
    _wallOrientation = nextOrientation;
    _previewWall = Wall(_previewWall!.row, _previewWall!.col, nextOrientation);
    notifyListeners();
  }

  void nudgePreviewWall(int dRow, int dCol) {
    if (_previewWall == null) {
      _previewWall = Wall(3, 3, _wallOrientation);
      notifyListeners();
      return;
    }
    final newRow = (_previewWall!.row + dRow).clamp(0, Wall.anchorCount - 1);
    final newCol = (_previewWall!.col + dCol).clamp(0, Wall.anchorCount - 1);
    _previewWall = Wall(newRow, newCol, _previewWall!.orientation);
    notifyListeners();
  }

  bool confirmPreviewWall() {
    if (_previewWall == null || !canPlaceWall) return false;
    final error = wallIllegalReason(_state, _previewWall!);
    if (error != null) {
      _statusMessage = error;
      notifyListeners();
      return false;
    }

    final wallToPlace = _previewWall!;
    _previewWall = null;
    _playMode = PlayMode.movePawn;
    return _applyPlacedWall(wallToPlace);
  }

  void togglePathOverlay() {
    _showPathOverlay = !_showPathOverlay;
    notifyListeners();
  }

  bool playPawnMove(Position target) {
    if (!isHumanTurn) return false;
    if (!legalMoves.contains(target)) return false;

    try {
      _state = applyMove(_state, PawnMove(target));
      _history.add(_state);
      _statusMessage = null;
      _lastAdvice = null;
      _previewWall = null;
      notifyListeners();

      if (!_state.isOver && _vsAi && _state.currentPlayer != _humanPlayer) {
        _triggerAiMove();
      }
      return true;
    } catch (e) {
      _statusMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool directPlaceWall(int row, int col) {
    if (!isHumanTurn || !canPlaceWall) return false;
    final wall = Wall(row, col, _wallOrientation);
    final error = wallIllegalReason(_state, wall);
    if (error != null) {
      // Show preview so player can see why it's illegal
      _previewWall = wall;
      _playMode = PlayMode.placeWall;
      _statusMessage = error;
      notifyListeners();
      return false;
    }

    _previewWall = null;
    _playMode = PlayMode.movePawn;
    return _applyPlacedWall(wall);
  }

  bool _applyPlacedWall(Wall wall) {
    try {
      _state = applyMove(_state, WallMove(wall));
      _history.add(_state);
      _statusMessage = null;
      _lastAdvice = null;
      _previewWall = null;
      notifyListeners();

      if (!_state.isOver && _vsAi && _state.currentPlayer != _humanPlayer) {
        _triggerAiMove();
      }
      return true;
    } catch (e) {
      _statusMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _triggerAiMove() async {
    _isAiThinking = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 550));

    if (_state.isOver) {
      _isAiThinking = false;
      notifyListeners();
      return;
    }

    try {
      final ai = createAi(_difficulty);
      final move = ai.chooseMove(_state);
      _state = applyMove(_state, move);
      _history.add(_state);

      if (move is WallMove) {
        _statusMessage =
            'AI placed a ${move.wall.isHorizontal ? 'Horizontal' : 'Vertical'} wall at (${move.wall.row}, ${move.wall.col})';
      } else if (move is PawnMove) {
        _statusMessage = 'AI moved pawn to (${move.to.row}, ${move.to.col})';
      }
    } catch (e) {
      _statusMessage = 'AI Error: $e';
    } finally {
      _isAiThinking = false;
      notifyListeners();
    }
  }

  void requestHint() {
    if (_state.isOver) return;
    _lastAdvice = AiCompanion.getHint(_state);
    if (_lastAdvice?.move is WallMove) {
      final w = (_lastAdvice!.move as WallMove).wall;
      _previewWall = w;
      _wallOrientation = w.orientation;
      _playMode = PlayMode.placeWall;
    }
    notifyListeners();
  }

  void clearHint() {
    _lastAdvice = null;
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    if (_vsAi) {
      if (_history.length >= 3) {
        _history.removeLast();
        _history.removeLast();
        _state = _history.last;
      } else if (_history.length == 2) {
        _history.removeLast();
        _state = _history.last;
      }
    } else {
      _history.removeLast();
      _state = _history.last;
    }
    _statusMessage = null;
    _lastAdvice = null;
    _previewWall = null;
    notifyListeners();
  }
}
