import 'package:chessudoku/enums/chess_piece.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessudoku/providers/game_provider.dart';
import 'package:chessudoku/models/cell.dart';

class BoardCell extends StatelessWidget {
  final int row;
  final int col;
  final Cell cell;

  const BoardCell({super.key, required this.row, required this.col, required this.cell});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final isSelected = gameProvider.isCellSelected(row, col);
    final isHighlighted = gameProvider.isCellHighlighted(row, col);
    final isWrong = gameProvider.isCellWrong(row, col);

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.blue.shade100;
    } else if (isHighlighted) {
      backgroundColor = Colors.blue.shade50;
    }

    // 3x3 박스 구분을 위한 테두리 설정
    final borderSide = BorderSide(color: Colors.grey.shade400, width: 0.5);
    final boldBorderSide = BorderSide(color: Colors.grey.shade400, width: 2.0);

    return GestureDetector(
      onTap: () => gameProvider.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: row % 3 == 0 ? boldBorderSide : borderSide,
            left: col % 3 == 0 ? boldBorderSide : borderSide,
            right: BorderSide.none,
            bottom: BorderSide.none,
          ),
        ),
        child: Center(child: _buildCellContent(isWrong)),
      ),
    );
  }

  Widget _buildCellContent(bool isWrong) {
    if (cell.piece != null) {
      return Text(_getPieceSymbol(cell.piece!), style: const TextStyle(fontSize: 24));
    }

    if (cell.number != null) {
      return Text(
        cell.number.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: cell.isInitial ? FontWeight.bold : FontWeight.normal,
          color:
              isWrong
                  ? Colors.red
                  : cell.isInitial
                  ? Colors.black
                  : Colors.blue,
        ),
      );
    }

    return const SizedBox();
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
