import 'atlas_completion_scope.dart';

final class AtlasTaxonomyNode {
  const AtlasTaxonomyNode({
    required this.scope,
    required this.id,
    required this.name,
    this.parentId,
    this.metadata = const <String, Object?>{},
  });

  /// What level of the taxonomy this node belongs to.
  final AtlasCompletionScope scope;

  /// Stable identifier.
  ///
  /// Examples:
  /// marvel
  /// spider_man
  /// no_way_home
  /// target
  /// chase
  final String id;

  /// User-facing name.
  ///
  /// Examples:
  /// Marvel
  /// Spider-Man
  /// No Way Home
  /// Target
  /// Chase
  final String name;

  /// Parent node identifier.
  ///
  /// Example:
  ///
  /// Spider-Man
  /// parentId -> marvel
  final String? parentId;

  /// Future-proof metadata.
  ///
  /// We intentionally keep this flexible so future catalog
  /// providers can attach additional information without
  /// changing the model.
  final Map<String, Object?> metadata;

  bool get hasParent {
    return parentId != null &&
        parentId!.trim().isNotEmpty;
  }

  bool get hasMetadata {
    return metadata.isNotEmpty;
  }

  AtlasTaxonomyNode copyWith({
    AtlasCompletionScope? scope,
    String? id,
    String? name,
    String? parentId,
    Map<String, Object?>? metadata,
  }) {
    return AtlasTaxonomyNode(
      scope: scope ?? this.scope,
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(
      Object other,
      ) {
    return identical(this, other) ||
        other is AtlasTaxonomyNode &&
            scope == other.scope &&
            id == other.id;
  }

  @override
  int get hashCode {
    return Object.hash(
      scope,
      id,
    );
  }

  @override
  String toString() {
    return '${scope.displayLabel}: $name';
  }
}