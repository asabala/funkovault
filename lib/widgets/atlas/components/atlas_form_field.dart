import 'package:flutter/material.dart';

import '../../../theme/atlas_spacing.dart';
import '../atlas_glass_panel.dart';

class AtlasFormField extends StatelessWidget {
  const AtlasFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.focusNode,
    this.keyboardType,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  final String? hintText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  final bool enabled;
  final TextInputAction? textInputAction;

  final int? maxLength;
  final int maxLines;
  final int? minLines;

  final TextCapitalization textCapitalization;

  final bool obscureText;
  final Widget? suffixIcon;

  final Iterable<String>? autofillHints;

  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        enabled: enabled,
        textInputAction: textInputAction,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        autofillHints: autofillHints,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AtlasSpacing.md,
            vertical: AtlasSpacing.md,
          ),
        ),
      ),
    );
  }
}