import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/providers/game_2_provider.dart';

class GameScreen2 extends StatefulWidget {
  final String difficulty;

  const GameScreen2({super.key, required this.difficulty});

  @override
  State<GameScreen2> createState() => _GameScreen2State();
}

class _GameScreen2State extends State<GameScreen2> {
  List<List<bool>> _incorrectCells = List.generate(9, (_) => List.filled(9, false));
  bool _showIncorrect = false;

  @override
  void initState() {
    super.initState();
    // 게임 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  Future<void> _initializeGame() async {
    final gameProvider = context.read<GameProvider2>();

    // TODO: API에서 퍼즐 데이터를 가져오는 로직 구현
    // 임시 테스트 데이터
    final initialBoard = Board(cells: List.generate(9, (row) => List.generate(9, (col) => Cell(type: CellType.empty))));

    final solutionBoard = Board(
      cells: List.generate(9, (row) => List.generate(9, (col) => Cell(type: CellType.empty))),
    );

    await gameProvider.initializeGame('test_puzzle_id', initialBoard, solutionBoard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Consumer<GameProvider2>(
          builder: (context, gameProvider, child) {
            if (gameProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (gameProvider.gameState == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load game'),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Return to Home')),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // 상단 정보 패널
                _buildInfoPanel(gameProvider),
                // 게임 보드
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(aspectRatio: 1, child: _buildGameBoard(context, gameProvider)),
                  ),
                ),
                // 숫자 입력 패드
                Expanded(flex: 2, child: _buildNumberPad(context, gameProvider)),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Chess Sudoku - ${widget.difficulty}', style: GoogleFonts.playfairDisplay()),
      actions: [
        IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () => _checkBoard(context),
          tooltip: '정답 확인',
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => _showResetConfirmDialog(context), tooltip: '리셋'),
      ],
    );
  }

  Widget _buildInfoPanel(GameProvider2 gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Time'),
              Text('00:00'), // TODO: 타이머 구현
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(BuildContext context, GameProvider2 gameProvider) {
    final board = gameProvider.gameState!.currentBoard;
    final selectedCell = gameProvider.gameState!.selectedCell;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final cell = board.getCell(row, col);
            final isSelected = selectedCell[0] == row && selectedCell[1] == col;
            final isIncorrect = _showIncorrect && _incorrectCells[row][col];

            return _buildCell(context, cell, row, col, isSelected, isIncorrect, gameProvider);
          },
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    Cell cell,
    int row,
    int col,
    bool isSelected,
    bool isIncorrect,
    GameProvider2 gameProvider,
  ) {
    // 3x3 박스 구분을 위한 테두리 설정
    final rightBorder = (col + 1) % 3 == 0 && col < 8;
    final bottomBorder = (row + 1) % 3 == 0 && row < 8;

    return GestureDetector(
      onTap: () => gameProvider.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: rightBorder ? 2 : 1, color: Colors.black),
            bottom: BorderSide(width: bottomBorder ? 2 : 1, color: Colors.black),
          ),
          color: _getCellColor(cell.type, isSelected, isIncorrect),
        ),
        child: Center(child: _getCellContent(cell)),
      ),
    );
  }

  Color _getCellColor(CellType type, bool isSelected, bool isIncorrect) {
    if (isIncorrect) return Colors.red.withOpacity(0.3);
    if (isSelected) return Colors.blue.withOpacity(0.3);

    switch (type) {
      case CellType.piece:
        return Colors.grey.withOpacity(0.1);
      case CellType.initial:
        return Colors.grey.withOpacity(0.1);
      case CellType.filled:
      case CellType.empty:
        return Colors.transparent;
    }
  }

  Widget _getCellContent(Cell cell) {
    switch (cell.type) {
      case CellType.piece:
        return Text(_getChessPieceSymbol(cell.piece!), style: const TextStyle(fontSize: 24));
      case CellType.initial:
      case CellType.filled:
        return Text(
          cell.number.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: cell.type == CellType.initial ? FontWeight.bold : FontWeight.normal,
            color: cell.type == CellType.initial ? Colors.black : Colors.blue[800],
          ),
        );
      case CellType.empty:
        return const SizedBox.shrink();
    }
  }

  String _getChessPieceSymbol(ChessPiece piece) {
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

  Widget _buildNumberPad(BuildContext context, GameProvider2 gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -2), blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Row(
              children: List.generate(5, (index) {
                return _buildNumberButton(context, index + 1, gameProvider);
              }),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                ...List.generate(4, (index) {
                  return _buildNumberButton(context, index + 6, gameProvider);
                }),
                _buildEraseButton(context, gameProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(BuildContext context, int number, GameProvider2 gameProvider) {
    final isEnabled = gameProvider.hasSelectedCell;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: isEnabled ? () => gameProvider.enterNumber(number) : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[800],
            disabledBackgroundColor: Colors.grey[200],
            elevation: isEnabled ? 2 : 0,
          ),
          child: Text(number.toString(), style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  Widget _buildEraseButton(BuildContext context, GameProvider2 gameProvider) {
    final isEnabled = gameProvider.hasSelectedCell;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: isEnabled ? () => gameProvider.clearNumber() : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red[900],
            disabledBackgroundColor: Colors.grey[200],
            elevation: isEnabled ? 2 : 0,
          ),
          child: const Icon(Icons.backspace_outlined),
        ),
      ),
    );
  }

  Future<void> _checkBoard(BuildContext context) async {
    final gameProvider = context.read<GameProvider2>();
    final incorrectCells = await gameProvider.checkCurrentBoard();

    setState(() {
      _incorrectCells = incorrectCells;
      _showIncorrect = true;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ㅁㄴㅇ'), duration: const Duration(seconds: 2)));

    // 3초 후 틀린 칸 표시 제거
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showIncorrect = false;
        });
      }
    });
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Game'),
            content: const Text('Are you sure you want to reset the game?\nThis will clear all your progress.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  // TODO: Implement reset functionality
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}
