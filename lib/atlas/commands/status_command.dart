import '../models/atlas_response.dart';
import '../services/atlas_service.dart';

// Atlas Status Skill
//
// Returns the current health of Atlas.

class StatusCommand {
  Future<AtlasResponse> execute() async {
    return AtlasResponse.success(
      title: 'Atlas Status',
      message: 'Atlas Online',
      source: 'Atlas',
      data: {
        'status': 'Online',
        'version': AtlasService.version,
        'motto': AtlasService.motto,
        'learning': 'Enabled',
        'memory': 'Loaded',
        'knowledge': 'Ready',
      },
    );
  }
}
