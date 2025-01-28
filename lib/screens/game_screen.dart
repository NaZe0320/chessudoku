import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/board/game_board.dart';
import '../widgets/board/cell.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // 빌드가 완료된 후 퍼즐 로드를 실행하도록 스케줄링
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPuzzle();
    });
  }

  Future<void> _loadPuzzle() async {
    final gameProvider = context.read<GameProvider>();
    await gameProvider.generatePuzzle(difficulty: widget.difficulty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 앱바
              _buildAppBar(context),

              // 게임 상태 표시
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  if (gameProvider.isLoading) {
                    return LinearProgressIndicator(backgroundColor: Colors.blue.shade800, color: Colors.white);
                  }
                  return const SizedBox(height: 4);
                },
              ),

              // 게임 보드
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // 난이도 표시
                          Text(
                            widget.difficulty.toUpperCase(),
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getDifficultyColor(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 게임 보드
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 24),
                                child: const AspectRatio(aspectRatio: 1, child: GameBoard()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 숫자 입력 패드
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    if (!gameProvider.hasSelectedCell) {
                      return Container(
                        height: 200,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Select a cell to enter a number',
                            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final selectedRow = gameProvider.selectedRow!;
                    final selectedCol = gameProvider.selectedCol!;
                    final validNumbers = gameProvider.getValidNumbers(selectedRow, selectedCol);

                    return NumberInputPad(
                      onNumberSelected: gameProvider.enterNumber,
                      onErase: gameProvider.eraseNumber,
                      availableNumbers: validNumbers,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 뒤로가기 버튼
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // 제목
          Text(
            'Chess Sudoku',
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          // 액션 버튼들
          Row(
            children: [
              // 힌트 토글 버튼
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  return IconButton(
                    icon: Icon(gameProvider.showHints ? Icons.lightbulb : Icons.lightbulb_outline, color: Colors.white),
                    onPressed: gameProvider.toggleHints,
                    tooltip: 'Toggle Hints',
                  );
                },
              ),
              // 새 게임 버튼
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => _showNewGameConfirmDialog(context),
                tooltip: 'New Game',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  void _showNewGameConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Start New Game?', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Current progress will be lost.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadPuzzle();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('New Game'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, size: 64, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text('Congratulations!', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('You have completed the puzzle!', style: GoogleFonts.lato(color: Colors.grey)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadPuzzle();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('New Game'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
