// tutorial_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chessudoku/enums/chess_piece.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: const [_BasicRulePage(), _ChessPiecesPage(), _GameplayPage(), _TipsPage()],
            ),
          ),
          // Page indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed:
                      _currentPage > 0
                          ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                          : null,
                  child: const Text('Previous'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    4,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Colors.blue.shade900 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      _currentPage < 3
                          ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                          : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicRulePage extends StatelessWidget {
  const _BasicRulePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Rules',
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _RuleCard(
            title: 'Sudoku Rules',
            content: 'Fill the 9×9 grid with numbers 1-9, ensuring each number appears:',
            rules: const ['Once in each row', 'Once in each column', 'Once in each 3×3 box'],
          ),
          const SizedBox(height: 16),
          _RuleCard(
            title: 'Chess Twist',
            content: 'Chess pieces on the board add special rules:',
            rules: const [
              'Numbers in cells affected by chess pieces must be unique',
              'Chess pieces cannot move but affect cells according to their movement patterns',
              'Multiple chess pieces can affect the same cell',
            ],
          ),
        ],
      ),
    );
  }
}

class _ChessPiecesPage extends StatelessWidget {
  const _ChessPiecesPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chess Pieces',
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _ChessPieceCard(
            piece: ChessPiece.king,
            symbol: '♚',
            title: 'King',
            description: 'Numbers in all adjacent cells (including diagonals) must be different.',
          ),
          const SizedBox(height: 12),
          _ChessPieceCard(
            piece: ChessPiece.bishop,
            symbol: '♝',
            title: 'Bishop',
            description: 'Numbers along each diagonal line must be different until blocked by another piece.',
          ),
          const SizedBox(height: 12),
          _ChessPieceCard(
            piece: ChessPiece.knight,
            symbol: '♞',
            title: 'Knight',
            description: 'Numbers in all cells reachable by L-shaped moves must be different.',
          ),
          const SizedBox(height: 12),
          _ChessPieceCard(
            piece: ChessPiece.rook,
            symbol: '♜',
            title: 'Rook',
            description:
                'Numbers along horizontal and vertical lines must be different until blocked by another piece.',
          ),
        ],
      ),
    );
  }
}

class _GameplayPage extends StatelessWidget {
  const _GameplayPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Play',
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _InstructionCard(
            icon: Icons.touch_app,
            title: 'Select & Input',
            instructions: const [
              'Tap a cell to select it',
              'Use the number pad to input numbers',
              'Tap the same number to clear the cell',
            ],
          ),
          const SizedBox(height: 12),
          _InstructionCard(
            icon: Icons.edit_note,
            title: 'Memo Mode',
            instructions: const [
              'Toggle memo mode to take notes',
              'Use numbers to add/remove candidates',
              'Helpful for tracking possibilities',
            ],
          ),
          const SizedBox(height: 12),
          _InstructionCard(
            icon: Icons.check_circle,
            title: 'Check Feature',
            instructions: const [
              'Use check button to verify your progress',
              'Wrong numbers will be highlighted in red',
              'Limited checks available per puzzle',
            ],
          ),
        ],
      ),
    );
  }
}

class _TipsPage extends StatelessWidget {
  const _TipsPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips & Strategies',
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _TipCard(
            icon: Icons.lightbulb,
            title: 'Start with Chess Pieces',
            content:
                'Begin by identifying cells affected by chess pieces. These have additional constraints that can help narrow down possibilities.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.grid_on,
            title: 'Use Traditional Techniques',
            content:
                'Standard Sudoku techniques like scanning and elimination still work. Look for cells with the fewest possibilities.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.edit_note,
            title: 'Take Notes',
            content:
                'Use the memo feature to keep track of possible numbers for each cell. Update these as you fill in numbers.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.psychology,
            title: 'Think Ahead',
            content:
                'Consider how placing a number might affect both Sudoku rules and chess piece constraints before making a move.',
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String title;
  final String content;
  final List<String> rules;

  const _RuleCard({required this.title, required this.content, required this.rules});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content),
            const SizedBox(height: 8),
            ...rules.map(
              (rule) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('• ', style: TextStyle(fontSize: 16)), Expanded(child: Text(rule))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChessPieceCard extends StatelessWidget {
  final ChessPiece piece;
  final String symbol;
  final String title;
  final String description;

  const _ChessPieceCard({required this.piece, required this.symbol, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(symbol, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> instructions;

  const _InstructionCard({required this.icon, required this.title, required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade900),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ...instructions.map(
              (instruction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('• ', style: TextStyle(fontSize: 16)), Expanded(child: Text(instruction))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _TipCard({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade900),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
