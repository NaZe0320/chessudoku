import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 게임 타이틀
                  Text(
                    'Chess Sudoku',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [const Shadow(offset: Offset(2, 2), blurRadius: 3.0, color: Colors.black26)],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 부제목
                  Text(
                    'A unique blend of Chess and Sudoku',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 64),

                  // 새 게임 시작 버튼
                  _MenuButton(
                    icon: Icons.play_arrow,
                    label: 'New Game',
                    onPressed: () => _showDifficultyDialog(context),
                  ),

                  const SizedBox(height: 16),

                  // 튜토리얼 버튼
                  _MenuButton(
                    icon: Icons.school,
                    label: 'How to Play',
                    onPressed: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorialScreen()));
                    },
                  ),

                  const SizedBox(height: 16),

                  // 설정 버튼
                  _MenuButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: () {
                      // TODO: Navigate to settings screen
                    },
                  ),

                  const SizedBox(height: 48),

                  // 체스 기물 아이콘들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('♚', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♝', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♞', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♜', style: TextStyle(color: Colors.white, fontSize: 32)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
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
                  Text('Select Difficulty', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _DifficultyOption(
                    difficulty: 'Easy',
                    description: '41-46 hints',
                    color: Colors.green,
                    onTap: () => _startGame(context, 'easy'),
                  ),
                  const SizedBox(height: 12),
                  _DifficultyOption(
                    difficulty: 'Medium',
                    description: '31-36 hints',
                    color: Colors.orange,
                    onTap: () => _startGame(context, 'medium'),
                  ),
                  const SizedBox(height: 12),
                  _DifficultyOption(
                    difficulty: 'Hard',
                    description: '21-26 hints',
                    color: Colors.red,
                    onTap: () => _startGame(context, 'hard'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _startGame(BuildContext context, String difficulty) {
    Navigator.of(context).pop(); // 난이도 선택 다이얼로그 닫기
    Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(difficulty: difficulty)));
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final String difficulty;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.difficulty,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: color), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.star, size: 16, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(difficulty, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
