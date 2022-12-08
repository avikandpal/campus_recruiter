import 'package:flutter/material.dart';

class MyTimer extends StatelessWidget {
  final AnimationController? controller;

  MyTimer(this.controller);

  String get timerString {
    // Duration? duration = controller?.duration * controller?.value;
    Duration? duration = controller?.duration;
    return '${duration?.inHours}:${(duration?.inMinutes ?? 0) % 60}:${((duration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}';
  }

  Duration? get duration {
    Duration? duration = controller?.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return AnimatedBuilder(
      animation: controller!,
      builder: (BuildContext context, Widget? child) {
        return Text(
          timerString,
          style: themeData.textTheme.displaySmall,
        );
      },
    );
  }
}
