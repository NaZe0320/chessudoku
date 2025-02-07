import 'package:chessudoku/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameControls extends StatelessWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Consumer<GameProvider>(
          builder:
              (context, provider, _) => _ControlButton(
                icon: provider.isMemoMode ? Icons.edit_note : Icons.edit,
                label: 'Memo',
                isActive: provider.isMemoMode,
                onPressed: () => provider.toggleMemoMode(),
              ),
        ),
        Consumer<GameProvider>(
          builder:
              (context, provider, _) => _ControlButton(
                icon: Icons.check_circle_outline,
                label: 'Check (${provider.remainingChecks})',
                onPressed: () => provider.checkCurrentInput(),
                isActive: false, // 체크 버튼은 항상 활성화 상태여야 함
              ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const _ControlButton({required this.icon, required this.label, required this.onPressed, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    // 메모 모드 토글 버튼의 경우에만 isActive 상태를 사용
    final bool isMemoButton = label == 'Memo';
    final Color color = isMemoButton && isActive ? Colors.blue : Colors.grey;

    return ElevatedButton.icon(
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: color)),
      onPressed: onPressed, // 항상 클릭 가능하도록 설정
    );
  }
}
