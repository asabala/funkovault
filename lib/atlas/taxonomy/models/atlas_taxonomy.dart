import 'dart:collection';

import 'atlas_completion_scope.dart';
import 'atlas_taxonomy_node.dart';

final class AtlasTaxonomy {
  AtlasTaxonomy({
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

  Set<AtlasCompletionScope> get scopes {
    return Set<AtlasCompletionScope>.unmodifiable(
      _nodes
          .map(
            (AtlasTaxonomyNode node) {
          return node.scope;
        },
      )
          .toSet(),
    );
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

  List<AtlasTaxonomyNode> nodesForScope(
      AtlasCompletionScope scope,
      ) {
    return List<AtlasTaxonomyNode>.unmodifiable(
      _nodes.where(
            (AtlasTaxonomyNode node) {
          return node.scope == scope;
        },
      ),
    );
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

  String? nameForScope(
      AtlasCompletionScope scope,
      ) {
    return nodeForScope(
      scope,
    )?.name;
  }

  String? idForScope(
      AtlasCompletionScope scope,
      ) {
    return nodeForScope(
      scope,
    )?.id;
  }

  Map<AtlasCompletionScope, List<AtlasTaxonomyNode>>
  get nodesByScope {
    final Map<
        AtlasCompletionScope,
        List<AtlasTaxonomyNode>>
    groupedNodes =
    <AtlasCompletionScope,
        List<AtlasTaxonomyNode>>{};

    for (final AtlasTaxonomyNode node
    in _nodes) {
      groupedNodes
          .putIfAbsent(
        node.scope,
            () => <AtlasTaxonomyNode>[],
      )
          .add(
        node,
      );
    }

    return UnmodifiableMapView<
        AtlasCompletionScope,
        List<AtlasTaxonomyNode>>(
      groupedNodes.map(
            (
            AtlasCompletionScope scope,
            List<AtlasTaxonomyNode> nodes,
            ) {
          return MapEntry<
              AtlasCompletionScope,
              List<AtlasTaxonomyNode>>(
            scope,
            List<AtlasTaxonomyNode>.unmodifiable(
              nodes,
            ),
          );
        },
      ),
    );
  }

  AtlasTaxonomy copyWith({
    Iterable<AtlasTaxonomyNode>? nodes,
  }) {
    return AtlasTaxonomy(
      nodes: nodes ?? _nodes,
    );
  }

  AtlasTaxonomy addNode(
      AtlasTaxonomyNode node,
      ) {
    return AtlasTaxonomy(
      nodes: <AtlasTaxonomyNode>[
        ..._nodes,
        node,
      ],
    );
  }

  AtlasTaxonomy addNodes(
      Iterable<AtlasTaxonomyNode> nodes,
      ) {
    return AtlasTaxonomy(
      nodes: <AtlasTaxonomyNode>[
        ..._nodes,
        ...nodes,
      ],
    );
  }

  AtlasTaxonomy withoutScope(
      AtlasCompletionScope scope,
      ) {
    return AtlasTaxonomy(
      nodes: _nodes.where(
            (AtlasTaxonomyNode node) {
          return node.scope != scope;
        },
      ),
    );
  }

  AtlasTaxonomy onlyScopes(
      Iterable<AtlasCompletionScope> scopes,
      ) {
    final Set<AtlasCompletionScope>
    includedScopes =
    scopes.toSet();

    return AtlasTaxonomy(
      nodes: _nodes.where(
            (AtlasTaxonomyNode node) {
          return includedScopes.contains(
            node.scope,
          );
        },
      ),
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

        final int nameComparison =
        first.name
            .toLowerCase()
            .compareTo(
          second.name.toLowerCase(),
        );

        if (nameComparison != 0) {
          return nameComparison;
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
      return 'AtlasTaxonomy(empty)';
    }

    return _nodes
        .map(
          (AtlasTaxonomyNode node) {
        return node.toString();
      },
    )
        .join(
      ' → ',
    );
  }
}