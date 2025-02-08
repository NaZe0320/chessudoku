import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chessudoku/utils/app_localizations.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;

  const PauseOverlay({super.key, required this.onResume});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black87,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pause_circle_outline, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('gamePaused'),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.translate('resumeGame')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
