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
            right: col == 8 ? boldBorderSide : BorderSide.none,
            bottom: row == 8 ? boldBorderSide : BorderSide.none,
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

    // 메모가 있을 경우 메모 그리드 표시
    if (cell.memos.isNotEmpty) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (index) {
          final number = index + 1;
          return Center(
            child:
                cell.memos.contains(number)
                    ? Text(number.toString(), style: const TextStyle(fontSize: 10, color: Colors.black87))
                    : const SizedBox(),
          );
        }),
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
