import '../../core/registry/atlas_module.dart';
import '../query/knowledge_query.dart';
import 'knowledge_provider_result.dart';

// Defines a source capable of supplying collectible identity knowledge.
//
// Providers may represent APIs, CSV datasets, barcode services, local
// databases, manual entry, scanners, or other trusted data sources.
abstract interface class KnowledgeProvider
    implements AtlasModule {
  // Determines whether this provider can handle the supplied query.
  bool supports(KnowledgeQuery query);

  // Retrieves zero or more identity candidates for the supplied query.
  Future<KnowledgeProviderResult> fetch(
      KnowledgeQuery query,
      );
}