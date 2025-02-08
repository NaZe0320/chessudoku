import 'package:flutter/material.dart';
import 'package:chessudoku/utils/app_localizations.dart';

class WarningDialog extends StatelessWidget {
  const WarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.translate('warning')),
      content: Text(l10n.translate('warningMessage')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.translate('cancel'))),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: Text(l10n.translate('continue')),
        ),
      ],
    );
  }
}
