import 'package:flutter/material.dart';

Future<bool?> showResetConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Reset Board'),
        content: const Text(
          'This will clear all your progress and restore the board to its initial state. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('RESET'),
          ),
        ],
      );
    },
  );
}
