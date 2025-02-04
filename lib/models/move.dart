import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:equatable/equatable.dart';

class Move extends Equatable {
  final int row;
  final int col;
  final Cell previousCell;
  final Cell newCell;

  const Move({required this.row, required this.col, required this.previousCell, required this.newCell});

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'previousCell': {
        'type': previousCell.type.toString(),
        'number': previousCell.number,
        'piece': previousCell.piece?.toString(),
        'isInitial': previousCell.isInitial,
        'memos': previousCell.memos.toList(),
      },
      'newCell': {
        'type': newCell.type.toString(),
        'number': newCell.number,
        'piece': newCell.piece?.toString(),
        'isInitial': newCell.isInitial,
        'memos': newCell.memos.toList(),
      },
    };
  }

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      row: json['row'],
      col: json['col'],
      previousCell: Cell(
        type: CellType.values.firstWhere((e) => e.toString() == json['previousCell']['type']),
        number: json['previousCell']['number'],
        piece:
            json['previousCell']['piece'] != null
                ? ChessPiece.values.firstWhere((e) => e.toString() == json['previousCell']['piece'])
                : null,
        isInitial: json['previousCell']['isInitial'],
        memos: Set<int>.from(json['previousCell']['memos']),
      ),
      newCell: Cell(
        type: CellType.values.firstWhere((e) => e.toString() == json['newCell']['type']),
        number: json['newCell']['number'],
        piece:
            json['newCell']['piece'] != null
                ? ChessPiece.values.firstWhere((e) => e.toString() == json['newCell']['piece'])
                : null,
        isInitial: json['newCell']['isInitial'],
        memos: Set<int>.from(json['newCell']['memos']),
      ),
    );
  }

  @override
  List<Object?> get props => [row, col, previousCell, newCell];
}
