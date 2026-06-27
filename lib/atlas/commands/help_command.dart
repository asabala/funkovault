import '../models/atlas_response.dart';

class HelpCommand {
  Future<AtlasResponse> execute() async {
    return AtlasResponse.success(
      title: 'Available Skills',
      message: '''
status
version
motto
help
''',
    );
  }
}