import 'package:flutter/material.dart';

/// Safe area for tab screens — bottom inset is handled by the nav bar.
class TabSafeArea extends StatelessWidget {
  final Widget child;

  const TabSafeArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: child);
  }
}
