import 'package:flutter/material.dart';

class VaultScrollView extends StatelessWidget {
  const VaultScrollView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 100),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        keyboardDismissBehavior:
        ScrollViewKeyboardDismissBehavior.onDrag,
        padding: padding,
        children: children,
      ),
    );
  }
}