import '../../core/result/atlas_result.dart';
import '../../core/registry/atlas_module.dart';
import '../../knowledge/mapper/knowledge_mapper_result.dart';
import 'identity_resolution_result.dart';

// Defines the contract for resolving candidate identity profiles into
// canonical identities.
abstract interface class IdentityResolver
    implements AtlasModule {
  // Resolves mapper results into canonical identity profiles.
  Future<AtlasResult<IdentityResolutionResult>> resolve({
    required List<KnowledgeMapperResult> mapperResults,
  });
}