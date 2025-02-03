import 'package:chessudoku/enums/chess_piece.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/cell.dart';

class SudokuBoard extends StatelessWidget {
  final Board board;
  final Function(int row, int col)? onCellTap;

  const SudokuBoard({super.key, required this.board, this.onCellTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // 정사각형 보드
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            return _buildCell(row, col);
          },
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final cell = board.getCell(row, col);
    // 3x3 박스 구분을 위한 테두리 설정
    final borderSide = BorderSide(color: Colors.grey.shade400, width: 0.5);

    final boldBorderSide = BorderSide(color: Colors.grey.shade400, width: 2.0);

    return GestureDetector(
      onTap: () => onCellTap?.call(row, col),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: row % 3 == 0 ? boldBorderSide : borderSide,
            left: col % 3 == 0 ? boldBorderSide : borderSide,
            right: BorderSide.none,
            bottom: BorderSide.none,
          ),
        ),
        child: Center(child: _buildCellContent(cell)),
      ),
    );
  }

  Widget _buildCellContent(Cell cell) {
    if (cell.piece != null) {
      return Text(_getPieceSymbol(cell.piece!), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
    }

    if (cell.number != null) {
      return Text(
        cell.number.toString(),
        style: TextStyle(
          fontSize: 24,
          color: cell.isInitial ? Colors.black : Colors.blue,
          fontWeight: cell.isInitial ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getPieceSymbol(ChessPiece piece) {
    switch (piece) {
      case ChessPiece.king:
        return '♚';
      case ChessPiece.bishop:
        return '♝';
      case ChessPiece.knight:
        return '♞';
      case ChessPiece.rook:
        return '♜';
    }
  }
}
