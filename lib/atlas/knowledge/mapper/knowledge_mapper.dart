import '../../core/registry/atlas_module.dart';
import '../record/knowledge_record.dart';
import 'knowledge_mapper_result.dart';

// Defines a translator between provider knowledge and Atlas identity.
//
// Mappers understand source record structures but do not compare
// identities or make final identity decisions.
abstract interface class KnowledgeMapper implements AtlasModule {
  // Determines whether this mapper understands the supplied record.
  bool supports(KnowledgeRecord record);

  // Converts one source record into zero or more identity profiles.
  KnowledgeMapperResult map(KnowledgeRecord record);
}
