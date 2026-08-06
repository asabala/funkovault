import 'dart:collection';

import 'atlas_completion_scope.dart';
import 'atlas_taxonomy_node.dart';

final class AtlasTaxonomyPath {
  AtlasTaxonomyPath({
    required Iterable<AtlasTaxonomyNode> nodes,
  }) : _nodes = List<AtlasTaxonomyNode>.unmodifiable(
    _normalizeNodes(
      nodes,
    ),
  );

  final List<AtlasTaxonomyNode> _nodes;

  List<AtlasTaxonomyNode> get nodes {
    return _nodes;
  }

  bool get isEmpty {
    return _nodes.isEmpty;
  }

  bool get isNotEmpty {
    return _nodes.isNotEmpty;
  }

  int get length {
    return _nodes.length;
  }

  AtlasTaxonomyNode? get firstOrNull {
    if (_nodes.isEmpty) {
      return null;
    }

    return _nodes.first;
  }

  AtlasTaxonomyNode? get lastOrNull {
    if (_nodes.isEmpty) {
      return null;
    }

    return _nodes.last;
  }

  AtlasTaxonomyNode? nodeForScope(
      AtlasCompletionScope scope,
      ) {
    for (final AtlasTaxonomyNode node
    in _nodes) {
      if (node.scope == scope) {
        return node;
      }
    }

    return null;
  }

  bool containsScope(
      AtlasCompletionScope scope,
      ) {
    return nodeForScope(
      scope,
    ) !=
        null;
  }

  bool containsNode({
    required AtlasCompletionScope scope,
    required String id,
  }) {
    final String normalizedId =
    id.trim().toLowerCase();

    if (normalizedId.isEmpty) {
      return false;
    }

    return _nodes.any(
          (AtlasTaxonomyNode node) {
        return node.scope == scope &&
            node.id.trim().toLowerCase() ==
                normalizedId;
      },
    );
  }

  AtlasTaxonomyPath addNode(
      AtlasTaxonomyNode node,
      ) {
    return AtlasTaxonomyPath(
      nodes: <AtlasTaxonomyNode>[
        ..._nodes,
        node,
      ],
    );
  }

  AtlasTaxonomyPath addNodes(
      Iterable<AtlasTaxonomyNode> nodes,
      ) {
    return AtlasTaxonomyPath(
      nodes: <AtlasTaxonomyNode>[
        ..._nodes,
        ...nodes,
      ],
    );
  }

  AtlasTaxonomyPath withoutScope(
      AtlasCompletionScope scope,
      ) {
    return AtlasTaxonomyPath(
      nodes: _nodes.where(
            (AtlasTaxonomyNode node) {
          return node.scope != scope;
        },
      ),
    );
  }

  AtlasTaxonomyPath upToScope(
      AtlasCompletionScope scope, {
        bool inclusive = true,
      }) {
    final int index = _nodes.indexWhere(
          (AtlasTaxonomyNode node) {
        return node.scope == scope;
      },
    );

    if (index < 0) {
      return AtlasTaxonomyPath(
        nodes: _nodes,
      );
    }

    final int endIndex =
    inclusive ? index + 1 : index;

    return AtlasTaxonomyPath(
      nodes: _nodes.take(
        endIndex,
      ),
    );
  }

  AtlasTaxonomyPath fromScope(
      AtlasCompletionScope scope, {
        bool inclusive = true,
      }) {
    final int index = _nodes.indexWhere(
          (AtlasTaxonomyNode node) {
        return node.scope == scope;
      },
    );

    if (index < 0) {
      return AtlasTaxonomyPath(
        nodes: _nodes,
      );
    }

    final int startIndex =
    inclusive ? index : index + 1;

    return AtlasTaxonomyPath(
      nodes: _nodes.skip(
        startIndex,
      ),
    );
  }

  Map<AtlasCompletionScope, AtlasTaxonomyNode>
  get nodesByScope {
    final Map<
        AtlasCompletionScope,
        AtlasTaxonomyNode>
    nodesByScope =
    <AtlasCompletionScope,
        AtlasTaxonomyNode>{};

    for (final AtlasTaxonomyNode node
    in _nodes) {
      nodesByScope.putIfAbsent(
        node.scope,
            () => node,
      );
    }

    return UnmodifiableMapView<
        AtlasCompletionScope,
        AtlasTaxonomyNode>(
      nodesByScope,
    );
  }

  static List<AtlasTaxonomyNode>
  _normalizeNodes(
      Iterable<AtlasTaxonomyNode> nodes,
      ) {
    final Map<String, AtlasTaxonomyNode>
    uniqueNodes =
    <String, AtlasTaxonomyNode>{};

    for (final AtlasTaxonomyNode node
    in nodes) {
      final String normalizedId =
      node.id.trim();

      final String normalizedName =
      node.name.trim();

      if (normalizedId.isEmpty ||
          normalizedName.isEmpty) {
        continue;
      }

      final String uniqueKey =
          '${node.scope.key}:'
          '${normalizedId.toLowerCase()}';

      uniqueNodes.putIfAbsent(
        uniqueKey,
            () {
          return AtlasTaxonomyNode(
            scope: node.scope,
            id: normalizedId,
            name: normalizedName,
            parentId:
            _normalizeOptionalText(
              node.parentId,
            ),
            metadata:
            Map<String, Object?>.unmodifiable(
              node.metadata,
            ),
          );
        },
      );
    }

    final List<AtlasTaxonomyNode>
    normalizedNodes =
    uniqueNodes.values.toList(
      growable: false,
    );

    normalizedNodes.sort(
          (
          AtlasTaxonomyNode first,
          AtlasTaxonomyNode second,
          ) {
        final int hierarchyComparison =
        first.scope.hierarchyOrder.compareTo(
          second.scope.hierarchyOrder,
        );

        if (hierarchyComparison != 0) {
          return hierarchyComparison;
        }

        return first.id
            .toLowerCase()
            .compareTo(
          second.id.toLowerCase(),
        );
      },
    );

    return normalizedNodes;
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
    if (_nodes.isEmpty) {
      return 'AtlasTaxonomyPath(empty)';
    }

    return _nodes
        .map(
          (AtlasTaxonomyNode node) {
        return node.name;
      },
    )
        .join(
      ' → ',
    );
  }
}