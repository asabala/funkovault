import 'package:flutter/material.dart';

import '../../../theme/atlas_spacing.dart';

class AtlasSearchField extends StatelessWidget {
  const AtlasSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.onClear,
    this.onSubmitted,
    this.hintText = 'Search Atlas...',
    this.autofocus = false,
    this.enabled = true,
    this.showClearButton = true,
    this.textInputAction = TextInputAction.search,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;

  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;

  final String hintText;

  final bool autofocus;
  final bool enabled;
  final bool showClearButton;

  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final bool showClear =
        showClearButton &&
            controller.text.isNotEmpty;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: showClear
            ? IconButton(
          tooltip: 'Clear Search',
          onPressed: onClear,
          icon: const Icon(
            Icons.close_rounded,
          ),
        )
            : null,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AtlasSpacing.md,
          vertical: AtlasSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}