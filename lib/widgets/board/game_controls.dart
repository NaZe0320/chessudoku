import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessudoku/providers/game_provider.dart';

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
        _ControlButton(
          icon: Icons.lightbulb_outline,
          label: 'Check',
          onPressed: () => context.read<GameProvider>().checkCurrentInput(),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;

  const _ControlButton({required this.icon, required this.label, this.onPressed, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: isActive ? Colors.blue : Colors.grey),
      label: Text(label, style: TextStyle(color: isActive ? Colors.blue : Colors.grey)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: isActive ? Colors.blue : Colors.grey),
      ),
      onPressed: onPressed,
    );
  }
}
