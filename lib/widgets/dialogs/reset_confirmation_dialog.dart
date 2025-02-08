import 'package:flutter/material.dart';
import 'package:chessudoku/utils/app_localizations.dart';

Future<bool?> showResetConfirmationDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(l10n.translate('resetBoard')),
        content: Text(l10n.translate('resetMessage')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.translate('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(l10n.translate('reset')),
          ),
        ],
      );
    },
  );
}
