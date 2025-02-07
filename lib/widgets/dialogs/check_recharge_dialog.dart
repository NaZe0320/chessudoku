// widgets/dialogs/check_recharge_dialog.dart

import 'package:flutter/material.dart';

class CheckRechargeDialog extends StatelessWidget {
  final VoidCallback onWatchAd;

  const CheckRechargeDialog({super.key, required this.onWatchAd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('No Checks Remaining'),
        ],
      ),
      content: const Text('Would you like to watch an ad to recharge 3 checks?', textAlign: TextAlign.center),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onWatchAd();
          },
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('WATCH AD'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
