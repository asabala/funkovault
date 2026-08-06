import 'package:funkovault2/atlas/taxonomy/models/atlas_completion_scope.dart';

final class AtlasCompletionFilter {
  const AtlasCompletionFilter({
    required this.scope,
    required this.nodeId,
    this.displayName,
  });

  final AtlasCompletionScope scope;
  final String nodeId;
  final String? displayName;

  bool get isValid {
    return nodeId.trim().isNotEmpty;
  }

  String get normalizedNodeId {
    return nodeId.trim().toLowerCase();
  }

  AtlasCompletionFilter copyWith({
    AtlasCompletionScope? scope,
    String? nodeId,
    String? displayName,
  }) {
    return AtlasCompletionFilter(
      scope: scope ?? this.scope,
      nodeId: nodeId ?? this.nodeId,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  bool operator ==(
      Object other,
      ) {
    return identical(this, other) ||
        other is AtlasCompletionFilter &&
            scope == other.scope &&
            normalizedNodeId ==
                other.normalizedNodeId;
  }

  @override
  int get hashCode {
    return Object.hash(
      scope,
      normalizedNodeId,
    );
  }
}

final class AtlasCompletionQuery {
  AtlasCompletionQuery({
    required Iterable<AtlasCompletionFilter> filters,
    this.primaryScope,
    this.includeWishlist = true,
    this.includeInactiveCatalogItems = false,
  }) : filters =
  List<AtlasCompletionFilter>.unmodifiable(
    _normalizeFilters(
      filters,
    ),
  );

  final List<AtlasCompletionFilter> filters;

  final AtlasCompletionScope? primaryScope;

  final bool includeWishlist;

  final bool includeInactiveCatalogItems;

  bool get isEmpty {
    return filters.isEmpty;
  }

  bool get isNotEmpty {
    return filters.isNotEmpty;
  }

  bool get isComposite {
    return filters.length > 1;
  }

  AtlasCompletionFilter? filterForScope(
      AtlasCompletionScope scope,
      ) {
    for (final AtlasCompletionFilter filter
    in filters) {
      if (filter.scope == scope) {
        return filter;
      }
    }

    return null;
  }

  bool containsScope(
      AtlasCompletionScope scope,
      ) {
    return filterForScope(
      scope,
    ) !=
        null;
  }

  AtlasCompletionQuery addFilter(
      AtlasCompletionFilter filter,
      ) {
    return AtlasCompletionQuery(
      filters: <AtlasCompletionFilter>[
        ...filters,
        filter,
      ],
      primaryScope: primaryScope,
      includeWishlist: includeWishlist,
      includeInactiveCatalogItems:
      includeInactiveCatalogItems,
    );
  }

  AtlasCompletionQuery removeScope(
      AtlasCompletionScope scope,
      ) {
    return AtlasCompletionQuery(
      filters: filters.where(
            (AtlasCompletionFilter filter) {
          return filter.scope != scope;
        },
      ),
      primaryScope:
      primaryScope == scope
          ? null
          : primaryScope,
      includeWishlist: includeWishlist,
      includeInactiveCatalogItems:
      includeInactiveCatalogItems,
    );
  }

  AtlasCompletionQuery copyWith({
    Iterable<AtlasCompletionFilter>? filters,
    AtlasCompletionScope? primaryScope,
    bool clearPrimaryScope = false,
    bool? includeWishlist,
    bool? includeInactiveCatalogItems,
  }) {
    return AtlasCompletionQuery(
      filters: filters ?? this.filters,
      primaryScope: clearPrimaryScope
          ? null
          : primaryScope ?? this.primaryScope,
      includeWishlist:
      includeWishlist ?? this.includeWishlist,
      includeInactiveCatalogItems:
      includeInactiveCatalogItems ??
          this.includeInactiveCatalogItems,
    );
  }

  static List<AtlasCompletionFilter>
  _normalizeFilters(
      Iterable<AtlasCompletionFilter> filters,
      ) {
    final Map<String, AtlasCompletionFilter>
    uniqueFilters =
    <String, AtlasCompletionFilter>{};

    for (final AtlasCompletionFilter filter
    in filters) {
      if (!filter.isValid) {
        continue;
      }

      final String key =
          '${filter.scope.key}:'
          '${filter.normalizedNodeId}';

      uniqueFilters.putIfAbsent(
        key,
            () {
          return AtlasCompletionFilter(
            scope: filter.scope,
            nodeId: filter.nodeId.trim(),
            displayName:
            _normalizeOptionalText(
              filter.displayName,
            ),
          );
        },
      );
    }

    final List<AtlasCompletionFilter>
    normalizedFilters =
    uniqueFilters.values.toList(
      growable: false,
    );

    normalizedFilters.sort(
          (
          AtlasCompletionFilter first,
          AtlasCompletionFilter second,
          ) {
        final int scopeComparison =
        first.scope.hierarchyOrder.compareTo(
          second.scope.hierarchyOrder,
        );

        if (scopeComparison != 0) {
          return scopeComparison;
        }

        return first.normalizedNodeId.compareTo(
          second.normalizedNodeId,
        );
      },
    );

    return normalizedFilters;
  }

  static String? _normalizeOptionalText(
      String? value,
      ) {
    final String normalized =
        value?.trim() ?? '';

    return normalized.isEmpty
        ? null
        : normalized;
  }

  @override
  String toString() {
    if (filters.isEmpty) {
      return 'AtlasCompletionQuery(empty)';
    }

    return filters
        .map(
          (AtlasCompletionFilter filter) {
        return '${filter.scope.key}:'
            '${filter.nodeId}';
      },
    )
        .join(
      ' AND ',
    );
  }
}