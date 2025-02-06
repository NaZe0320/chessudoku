import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessudoku/providers/game_provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return SizedBox(
      width: 300, // 전체 너비 지정
      child: GridView.count(
        crossAxisCount: 5, // 한 줄에 5개
        shrinkWrap: true,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
        children: [
          ...List.generate(9, (index) {
            final number = index + 1;
            return _NumberButton(
              number: number,
              onPressed: gameProvider.hasSelectedCell ? () => gameProvider.inputNumber(number) : null,
            );
          }),
          _NumberButton(
            icon: Icons.delete,
            onPressed: gameProvider.hasSelectedCell ? () => gameProvider.clearCell() : null,
          ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int? number;
  final IconData? icon;
  final VoidCallback? onPressed;

  const _NumberButton({this.number, this.icon, this.onPressed}) : assert(number != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(icon, size: 24)
                  : Text(number.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
