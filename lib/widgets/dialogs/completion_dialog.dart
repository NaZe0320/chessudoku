import 'package:flutter/material.dart';
import 'package:chessudoku/utils/helpers.dart';
import 'package:chessudoku/utils/app_localizations.dart';

class CompletionDialog extends StatefulWidget {
  final int elapsedSeconds;
  final int hintsUsed;
  final String difficulty;
  final Function(int rating, String? comment) onRate;

  const CompletionDialog({
    super.key,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.difficulty,
    required this.onRate,
  });

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                l10n.translate('puzzleCompleted'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildStatRow(context, l10n.translate('time'), formatDuration(Duration(seconds: widget.elapsedSeconds))),
              const SizedBox(height: 8),
              _buildStatRow(context, l10n.translate('difficulty'), l10n.translate(widget.difficulty.toLowerCase())),
              const SizedBox(height: 8),
              _buildStatRow(context, l10n.translate('hintsUsed'), widget.hintsUsed.toString()),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(l10n.translate('ratePuzzle'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      iconSize: 32,
                      padding: EdgeInsets.zero,
                      icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                      onPressed: () => setState(() => _rating = index + 1),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(hintText: l10n.translate('addComment'), border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  widget.onRate(_rating, _commentController.text.trim());
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(l10n.translate('continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
