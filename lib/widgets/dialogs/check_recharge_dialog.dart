import 'package:flutter/material.dart';
import 'package:chessudoku/utils/app_localizations.dart';

class CheckRechargeDialog extends StatelessWidget {
  final VoidCallback onWatchAd;

  const CheckRechargeDialog({super.key, required this.onWatchAd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          Text(l10n.translate('noChecksRemaining')),
        ],
      ),
      content: Text(l10n.translate('watchAdForChecks'), textAlign: TextAlign.center),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.translate('cancel'))),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onWatchAd();
          },
          icon: const Icon(Icons.play_circle_outline),
          label: Text(l10n.translate('watchAd')),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
