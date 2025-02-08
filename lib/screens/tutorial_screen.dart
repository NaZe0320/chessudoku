import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/utils/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('howToPlayTitle')),
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
                  child: Text(l10n.translate('previous')),
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
                  child: Text(l10n.translate('next')),
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
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('basicRules'),
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _RuleCard(
            title: l10n.translate('sudokuRulesTitle'),
            content: l10n.translate('sudokuRulesContent'),
            rules: [l10n.translate('sudokuRule1'), l10n.translate('sudokuRule2'), l10n.translate('sudokuRule3')],
          ),
          const SizedBox(height: 16),
          _RuleCard(
            title: l10n.translate('chessTwistTitle'),
            content: l10n.translate('chessTwistContent'),
            rules: [
              l10n.translate('chessTwistRule1'),
              l10n.translate('chessTwistRule2'),
              l10n.translate('chessTwistRule3'),
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
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('chessPieces'),
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _ChessPieceCard(
            piece: ChessPiece.king,
            symbol: '♚',
            title: l10n.translate('kingTitle'),
            description: l10n.translate('kingDescription'),
          ),
          const SizedBox(height: 12),
          _ChessPieceCard(
            piece: ChessPiece.bishop,
            symbol: '♝',
            title: l10n.translate('bishopTitle'),
            description: l10n.translate('bishopDescription'),
          ),
          const SizedBox(height: 12),
          _ChessPieceCard(
            piece: ChessPiece.knight,
            symbol: '♞',
            title: l10n.translate('knightTitle'),
            description: l10n.translate('knightDescription'),
          ),
          const SizedBox(height: 12),
          _ChessPieceCard(
            piece: ChessPiece.rook,
            symbol: '♜',
            title: l10n.translate('rookTitle'),
            description: l10n.translate('rookDescription'),
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
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('howToPlayTitle'),
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _InstructionCard(
            icon: Icons.touch_app,
            title: l10n.translate('selectInputTitle'),
            instructions: [
              l10n.translate('selectInputRule1'),
              l10n.translate('selectInputRule2'),
              l10n.translate('selectInputRule3'),
            ],
          ),
          const SizedBox(height: 12),
          _InstructionCard(
            icon: Icons.edit_note,
            title: l10n.translate('memoModeTitle'),
            instructions: [
              l10n.translate('memoModeRule1'),
              l10n.translate('memoModeRule2'),
              l10n.translate('memoModeRule3'),
            ],
          ),
          const SizedBox(height: 12),
          _InstructionCard(
            icon: Icons.check_circle,
            title: l10n.translate('checkFeatureTitle'),
            instructions: [
              l10n.translate('checkFeatureRule1'),
              l10n.translate('checkFeatureRule2'),
              l10n.translate('checkFeatureRule3'),
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
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('tipsAndStrategies'),
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 16),
          _TipCard(
            icon: Icons.lightbulb,
            title: l10n.translate('startWithChessTitle'),
            content: l10n.translate('startWithChessContent'),
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.grid_on,
            title: l10n.translate('traditionalTechTitle'),
            content: l10n.translate('traditionalTechContent'),
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.edit_note,
            title: l10n.translate('takeNotesTitle'),
            content: l10n.translate('takeNotesContent'),
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.psychology,
            title: l10n.translate('thinkAheadTitle'),
            content: l10n.translate('thinkAheadContent'),
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
