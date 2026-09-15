import '../../core/registry/atlas_registry.dart';
import '../record/knowledge_record.dart';
import 'knowledge_mapper.dart';
import 'knowledge_mapper_result.dart';

// Registry containing the available Atlas knowledge mappers.
//
// Generic module storage and discovery are handled by AtlasRegistry.
// This class retains knowledge-mapping support checks and execution.
class KnowledgeMapperRegistry {
  KnowledgeMapperRegistry(List<KnowledgeMapper> mappers)
    : _registry = AtlasRegistry<KnowledgeMapper>(mappers);

  final AtlasRegistry<KnowledgeMapper> _registry;

  List<KnowledgeMapper> get mappers {
    return _registry.modules;
  }

  bool get isEmpty => _registry.isEmpty;

  bool get isNotEmpty => _registry.isNotEmpty;

  int get length => _registry.length;

  Set<String> get mapperIds => _registry.ids;

  List<String> get mapperNames => _registry.names;

  Map<String, String> get mapperVersions {
    return _registry.versions;
  }

  KnowledgeMapper? byId(String id) {
    return _registry.byId(id);
  }

  bool contains(String id) {
    return _registry.contains(id);
  }

  // Returns only mappers that understand the supplied record.
  List<KnowledgeMapper> supportedMappers(KnowledgeRecord record) {
    return _registry.where((KnowledgeMapper mapper) {
      return mapper.supports(record);
    });
  }

  // Executes every mapper that supports the supplied record.
  //
  // Results remain separated so the future Identity Resolver can
  // evaluate mapper confidence, provenance, and conflicting mappings.
  List<KnowledgeMapperResult> mapAll(KnowledgeRecord record) {
    final List<KnowledgeMapper> supported = supportedMappers(record);

    final List<KnowledgeMapperResult> results = <KnowledgeMapperResult>[];

    for (final KnowledgeMapper mapper in supported) {
      results.add(mapper.map(record));
    }

    return List<KnowledgeMapperResult>.unmodifiable(results);
  }

  // Executes one specific mapper when it supports the record.
  //
  // Returns null when the mapper is not registered or does not
  // understand the supplied source record.
  KnowledgeMapperResult? mapWith({
    required String mapperId,
    required KnowledgeRecord record,
  }) {
    final KnowledgeMapper? mapper = byId(mapperId);

    if (mapper == null || !mapper.supports(record)) {
      return null;
    }

    return mapper.map(record);
  }
}
