import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessudoku/providers/game_provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 숫자 입력 패드 (1-9)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(9, (index) {
              final number = index + 1;
              return SizedBox(
                width: 50,
                height: 50,
                child: ElevatedButton(
                  onPressed: gameProvider.hasSelectedCell ? () => gameProvider.inputNumber(number) : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: Center(
                    child: Text(number.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // 컨트롤 버튼들 (지우기, 힌트 등)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                icon: Icons.delete,
                label: 'Clear',
                onPressed: gameProvider.hasSelectedCell ? () => gameProvider.clearCell() : null,
              ),
              _ControlButton(
                icon: Icons.lightbulb_outline,
                label: 'Check',
                onPressed: () => gameProvider.checkCurrentInput(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ControlButton({required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue.shade900,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
