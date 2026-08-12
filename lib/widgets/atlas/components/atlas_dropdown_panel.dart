import 'package:flutter/material.dart';

import '../atlas_glass_panel.dart';

class AtlasDropdownPanel extends StatelessWidget {
  const AtlasDropdownPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: child,
    );
  }
}