import '../../core/registry/atlas_registry.dart';
import '../query/knowledge_query.dart';
import 'knowledge_provider.dart';
import 'knowledge_provider_result.dart';

// Registry containing the available Atlas knowledge providers.
//
// Generic storage and discovery behavior is handled by AtlasRegistry.
// This class retains knowledge-specific support checks and execution.
class KnowledgeProviderRegistry {
  KnowledgeProviderRegistry(List<KnowledgeProvider> providers)
    : _registry = AtlasRegistry<KnowledgeProvider>(providers);

  final AtlasRegistry<KnowledgeProvider> _registry;

  List<KnowledgeProvider> get providers {
    return _registry.modules;
  }

  bool get isEmpty => _registry.isEmpty;

  bool get isNotEmpty => _registry.isNotEmpty;

  int get length => _registry.length;

  Set<String> get providerIds => _registry.ids;

  List<String> get providerNames => _registry.names;

  Map<String, String> get providerVersions {
    return _registry.versions;
  }

  KnowledgeProvider? byId(String id) {
    return _registry.byId(id);
  }

  bool contains(String id) {
    return _registry.contains(id);
  }

  // Returns only providers capable of handling the supplied query.
  List<KnowledgeProvider> supportedProviders(KnowledgeQuery query) {
    return _registry.where((KnowledgeProvider provider) {
      return provider.supports(query);
    });
  }

  // Executes all providers that support the supplied query.
  //
  // Results remain separated by provider so a future resolver can
  // evaluate source confidence, conflicts, and supporting evidence.
  Future<List<KnowledgeProviderResult>> fetchAll(KnowledgeQuery query) async {
    final List<KnowledgeProvider> supported = supportedProviders(query);

    final List<KnowledgeProviderResult> results = <KnowledgeProviderResult>[];

    for (final KnowledgeProvider provider in supported) {
      final KnowledgeProviderResult result = await provider.fetch(query);

      results.add(result);
    }

    return List<KnowledgeProviderResult>.unmodifiable(results);
  }

  // Executes one specific provider when it supports the query.
  //
  // Returns null when the provider is not registered or cannot handle
  // the supplied request.
  Future<KnowledgeProviderResult?> fetchFrom({
    required String providerId,
    required KnowledgeQuery query,
  }) async {
    final KnowledgeProvider? provider = byId(providerId);

    if (provider == null || !provider.supports(query)) {
      return null;
    }

    return provider.fetch(query);
  }
}
