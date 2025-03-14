// completion_dialog.dart

import 'package:flutter/material.dart';
import 'package:chessudoku/utils/helpers.dart';

class CompletionDialog extends StatelessWidget {
  final int elapsedSeconds;
  final int hintsUsed;
  final String difficulty;

  const CompletionDialog({super.key, required this.elapsedSeconds, required this.hintsUsed, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Puzzle Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildStatRow('Time', formatDuration(Duration(seconds: elapsedSeconds))),
            const SizedBox(height: 8),
            _buildStatRow('Difficulty', difficulty),
            const SizedBox(height: 8),
            _buildStatRow('Hints Used', hintsUsed.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
