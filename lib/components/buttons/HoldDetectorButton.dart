import 'dart:async';
import 'package:flutter/material.dart';

class HoldDetectorButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onHold; // Logic to run repeatedly
  final VoidCallback? onTap; // Optional: logic for a single quick tap
  final VoidCallback? onStop; 
  final Duration interval;   // How fast the repeat happens

  const HoldDetectorButton({
    super.key,
    required this.child,
    required this.onHold,
    this.onStop,
    this.onTap,
    this.interval = const Duration(milliseconds: 100),
  });

  @override
  State<HoldDetectorButton> createState() => _HoldDetectorButtonState();
}

class _HoldDetectorButtonState extends State<HoldDetectorButton> {
  Timer? _timer;

  void _startTimer() {
    // Run the logic once immediately on touch
    widget.onHold(); 
    // Start the periodic timer for the "hold" effect
    _timer = Timer.periodic(widget.interval, (timer) {
      widget.onHold();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.onStop != null) widget.onStop!();
  }

  @override
  void dispose() {
    _stopTimer(); // Ensure timer is killed if widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _startTimer(),
      onPointerUp: (_) => _stopTimer(),
      onPointerCancel: (_) => _stopTimer(),
      child: ElevatedButton(
        onPressed: widget.onTap ?? () {}, // Handle quick tap if provided
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(30)),
        child: widget.child,
      ),
    );
  }
}