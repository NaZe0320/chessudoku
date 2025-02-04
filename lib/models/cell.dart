import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:equatable/equatable.dart';

class Cell extends Equatable {
  final CellType type;
  final int? number;
  final ChessPiece? piece;
  final bool isInitial;
  final Set<int> memos;

  const Cell({required this.type, this.number, this.piece, this.isInitial = false, this.memos = const {}});

  @override
  List<Object?> get props => [type, number, piece, isInitial, memos];

  Cell copyWith({CellType? type, int? number, ChessPiece? piece, bool? isInitial, Set<int>? memos}) {
    return Cell(
      type: type ?? this.type,
      number: number ?? this.number,
      piece: piece ?? this.piece,
      isInitial: isInitial ?? this.isInitial,
      memos: memos ?? this.memos,
    );
  }
}
