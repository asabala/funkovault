import 'package:flutter/material.dart';

import '../../theme/atlas_spacing.dart';

class VaultScrollView extends StatelessWidget {
  const VaultScrollView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(
      AtlasSpacing.lg,
      AtlasSpacing.lg,
      AtlasSpacing.lg,
      100,
    ),
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