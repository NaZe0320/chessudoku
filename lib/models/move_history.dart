import 'package:chessudoku/models/move.dart';
import 'package:equatable/equatable.dart';

class MoveHistory extends Equatable {
  final List<Move> moves;

  const MoveHistory({this.moves = const []});

  void addMove(Move move) {
    moves.add(move);
  }

  Move? undo() {
    if (moves.isEmpty) return null;
    return moves.removeLast();
  }

  bool get canUndo => moves.isNotEmpty;

  void clear() {
    moves.clear();
  }

  int get length => moves.length;

  Map<String, dynamic> toJson() {
    return {'moves': moves.map((move) => move.toJson()).toList()};
  }

  factory MoveHistory.fromJson(Map<String, dynamic> json) {
    return MoveHistory(moves: (json['moves'] as List).map((moveJson) => Move.fromJson(moveJson)).toList());
  }

  @override
  List<Object?> get props => [moves];
}
