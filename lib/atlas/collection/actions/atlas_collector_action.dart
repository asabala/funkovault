
import 'package:flutter/material.dart';

enum AtlasCollectorActionType {
  viewExistingItem,
  addToVault,
  addAnotherCopy,
  addToWishlist,
  removeFromWishlist,
  scanAnother,
}

@immutable
class AtlasCollectorAction {
  const AtlasCollectorAction({
    required this.type,
    required this.label,
    required this.icon,
    required this.emoji,
    required this.priority,
    this.isPrimary = false,
  });

  final AtlasCollectorActionType type;
  final String label;
  final IconData icon;
  final String emoji;
  final int priority;
  final bool isPrimary;

  String get displayLabel {
    return '$emoji $label';
  }

  AtlasCollectorAction copyWith({
    AtlasCollectorActionType? type,
    String? label,
    IconData? icon,
    String? emoji,
    int? priority,
    bool? isPrimary,
  }) {
    return AtlasCollectorAction(
      type: type ?? this.type,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      emoji: emoji ?? this.emoji,
      priority: priority ?? this.priority,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasCollectorAction &&
            runtimeType == other.runtimeType &&
            type == other.type &&
            label == other.label &&
            icon == other.icon &&
            emoji == other.emoji &&
            priority == other.priority &&
            isPrimary == other.isPrimary;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      label,
      icon,
      emoji,
      priority,
      isPrimary,
    );
  }
}