// lib/main.dart

import 'package:flutter/material.dart';

/// Widget to handle animated transitions
class AnimatedSwitcherWidget extends StatelessWidget {
  final Widget child;
  final String keyValue;

  const AnimatedSwitcherWidget({
    super.key,
    required this.child,
    required this.keyValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}
