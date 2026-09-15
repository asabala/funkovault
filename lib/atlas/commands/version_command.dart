import '../models/atlas_response.dart';
import '../services/atlas_service.dart';

class VersionCommand {
  Future<AtlasResponse> execute() async {
    return AtlasResponse.success(
      title: 'Atlas Version',
      message: AtlasService.version,
    );
  }
}
