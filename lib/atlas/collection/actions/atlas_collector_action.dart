import 'package:flutter/material.dart';

enum AtlasCollectorActionType {
  viewExistingItem,
  addToVault,
  addAnotherCopy,
  reviewVariantSticker,
  updateCondition,
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
    required this.priority,
    this.isPrimary = false,
  });

  final AtlasCollectorActionType type;
  final String label;
  final IconData icon;
  final int priority;
  final bool isPrimary;

  AtlasCollectorAction copyWith({
    AtlasCollectorActionType? type,
    String? label,
    IconData? icon,
    int? priority,
    bool? isPrimary,
  }) {
    return AtlasCollectorAction(
      type: type ?? this.type,
      label: label ?? this.label,
      icon: icon ?? this.icon,
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
            priority == other.priority &&
            isPrimary == other.isPrimary;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      label,
      icon,
      priority,
      isPrimary,
    );
  }
}