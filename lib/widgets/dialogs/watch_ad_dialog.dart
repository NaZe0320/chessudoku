import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chessudoku/utils/helpers.dart';

class WatchAdDialog extends StatefulWidget {
  final Duration? nextRecharge;
  final VoidCallback onWatchAd;

  const WatchAdDialog({super.key, required this.nextRecharge, required this.onWatchAd});

  @override
  State<WatchAdDialog> createState() => _WatchAdDialogState();
}

class _WatchAdDialogState extends State<WatchAdDialog> {
  Timer? _timer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.nextRecharge;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == null || _remainingTime! <= Duration.zero) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _remainingTime = _remainingTime! - const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          const Icon(Icons.video_library, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('No Chances Left'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Would you like to watch a video ad to get an extra chance?', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (_remainingTime != null && _remainingTime! > Duration.zero) ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Next free chance in: ${formatDuration(_remainingTime!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: widget.onWatchAd,
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Watch Ad'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
