import 'package:flutter/material.dart';

class AcademyTrackSelectorItem {
  const AcademyTrackSelectorItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isAvailable,
    this.badge,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isAvailable;
  final String? badge;
}