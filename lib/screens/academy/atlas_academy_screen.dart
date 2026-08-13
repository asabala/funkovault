import 'package:flutter/material.dart';

import '../../academy/academy_ids.dart';
import '../../academy/config/academy_admin_config.dart';
import '../../academy/config/academy_request_repository_provider.dart';
import '../../academy/engines/academy_explainer_engine.dart';
import '../../academy/helpers/academy_request_message_builder.dart';
import '../../academy/helpers/ask_atlas_suggestions_builder.dart';
import '../../academy/models/academy_category.dart';
import '../../academy/models/academy_lesson.dart';
import '../../academy/models/academy_request.dart';
import '../../academy/models/academy_request_submission_result.dart';
import '../../academy/models/academy_topic.dart';
import '../../academy/models/academy_track.dart';
import '../../academy/repository/academy_repository.dart';
import '../../academy/repository/academy_request_repository_contract.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/academy/admin/academy_local_admin_tools_section.dart';
import '../../widgets/academy/ask_atlas/ask_atlas_bottom_sheet_launcher.dart';
import '../../widgets/academy/shared/academy_hero_header.dart';
import '../../widgets/academy/shared/academy_snackbars.dart';
import '../../widgets/academy/tracks/academy_coming_soon_track_section.dart';
import '../../widgets/academy/tracks/academy_track_selector_card.dart';
import '../../widgets/academy/tracks/funko_academy_track_section.dart';
import 'academy_category_screen.dart';
import 'academy_lesson_screen.dart';

class AtlasAcademyScreen extends StatefulWidget {
  const AtlasAcademyScreen({
    super.key,
    this.requestRepository,
    this.showLocalAdminTools,
  });

  final AcademyRequestRepositoryContract? requestRepository;
  final bool? showLocalAdminTools;

  @override
  State<AtlasAcademyScreen> createState() {
    return _AtlasAcademyScreenState();
  }
}

class _AtlasAcademyScreenState extends State<AtlasAcademyScreen> {
  static const AcademyRepository _repository = AcademyRepository();

  static const AcademyExplainerEngine _explainerEngine =
      AcademyExplainerEngine();

  late final AcademyRequestRepositoryContract _requestRepository;

  String _selectedTrackId = AcademyTrackIds.funkoCollecting;

  List<AcademyRequest> get _adminRequests {
    return _requestRepository.getRequests();
  }

  int get _newAdminRequestCount {
    return _requestRepository.getNewRequestCount();
  }

  List<AcademyTrack> get _tracks {
    return _repository.getTracks();
  }

  AcademyTrack get _selectedTrack {
    return _tracks.firstWhere(
      (track) => track.id == _selectedTrackId,
      orElse: () => _tracks.first,
    );
  }

  bool get _isFunkoTrackSelected {
    return _selectedTrackId == AcademyTrackIds.funkoCollecting;
  }

  bool get _shouldShowLocalAdminTools {
    return AcademyAdminConfig.showLocalAdminTools &&
        (widget.showLocalAdminTools ?? true) &&
        _requestRepository.storageBehavior ==
            AcademyRequestStorageBehavior.sessionOnly;
  }

  @override
  void initState() {
    super.initState();

    _requestRepository =
        widget.requestRepository ?? AcademyRequestRepositoryProvider.create();
  }

  List<AcademyCategory> get _funkoCategories {
    return _repository.getCategoriesForTrack(AcademyTrackIds.funkoCollecting);
  }

  List<AcademyTopic> get _funkoRoadmapTopics {
    return _repository
        .getRoadmapTopicsForTrack(AcademyTrackIds.funkoCollecting)
        .take(8)
        .toList(growable: false);
  }

  List<String> get _askAtlasSuggestions {
    return AskAtlasSuggestionsBuilder.buildFunkoSuggestions(
      repository: _repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atlas Academy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AtlasSpacing.md,
          AtlasSpacing.sm,
          AtlasSpacing.md,
          AtlasSpacing.xl,
        ),
        children: [
          const AcademyHeroHeader(
            title: 'Become a smarter collector.',
            subtitle:
                'Learn collector terms, variants, stickers, figure types, values, and collecting tips directly inside Atlas.',
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AcademyTrackSelectorCard(
            title: 'Choose Your Academy Track',
            subtitle:
                'Follow a learning path built around how collectors actually grow their vault.',
            tracks: _tracks,
            selectedTrackId: _selectedTrackId,
            onTrackSelected: _handleTrackSelected,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (_isFunkoTrackSelected)
            FunkoAcademyTrackSection(
              track: _selectedTrack,
              categories: _funkoCategories,
              roadmapTopics: _funkoRoadmapTopics,
              askAtlasSuggestions: _askAtlasSuggestions,
              onAskAtlasQuestion: _handleAskAtlasQuestion,
              onOpenCategory: _openCategory,
              requestStorageBehavior: _requestRepository.storageBehavior,
              onTopicRequestSubmitted: _requestRepository.canSubmitRequests
                  ? _handleTopicRequestSubmitted
                  : null,
            )
          else
            AcademyComingSoonTrackSection(
              track: _selectedTrack,
              requestStorageBehavior: _requestRepository.storageBehavior,
              onNotifyTap: _requestRepository.canSubmitRequests
                  ? _handleTrackRequestSubmitted
                  : null,
            ),
          if (_shouldShowLocalAdminTools) ...[
            const SizedBox(height: AtlasSpacing.lg),
            AcademyLocalAdminToolsSection(
              newRequestCount: _newAdminRequestCount,
              requests: _adminRequests,
              onReviewTap: _handleRequestReviewed,
              onApproveTap: _handleRequestApproved,
              onDeclineTap: _handleRequestDeclined,
            ),
          ],
        ],
      ),
    );
  }

  void _handleTrackSelected(String trackId) {
    final AcademyTrack selectedTrack = _tracks.firstWhere(
      (track) => track.id == trackId,
      orElse: () => _tracks.first,
    );

    if (_selectedTrackId != selectedTrack.id) {
      setState(() {
        _selectedTrackId = selectedTrack.id;
      });
    }

    if (!selectedTrack.isAvailable) {
      AcademySnackbars.showComingSoonTrack(
        context: context,
        trackTitle: selectedTrack.title,
      );
    }
  }

  void _handleAskAtlasQuestion(String question) {
    AskAtlasBottomSheetLauncher.show(
      context: context,
      question: question,
      repository: _repository,
      explainerEngine: _explainerEngine,
      onOpenLesson: _openLesson,
    );
  }

  void _openCategory(AcademyCategory category) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AcademyCategoryScreen(category: category),
      ),
    );
  }

  void _openLesson(AcademyLesson lesson) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AcademyLessonScreen(lesson: lesson),
      ),
    );
  }

  Future<bool> _handleTopicRequestSubmitted(String topic) async {
    final String cleanedTopic = topic.trim();

    if (cleanedTopic.isEmpty) {
      return false;
    }

    late final AcademyRequestSubmissionResult result;

    try {
      result = await _requestRepository.submitTopicRequest(
        topic: cleanedTopic,
        trackId: AcademyTrackIds.funkoCollecting,
      );
    } catch (_) {
      if (mounted) {
        AcademySnackbars.showRequestSubmissionFailed(context: context);
      }

      return false;
    }

    if (!mounted) {
      return result.isSuccessful;
    }

    if (!result.isSuccessful) {
      _showUnsuccessfulSubmission(result);
      return false;
    }

    setState(() {});

    AcademySnackbars.showTopicRequestSubmitted(
      context: context,
      topic: result.request?.title ?? cleanedTopic,
      newRequestCount: _newAdminRequestCount,
      storageBehavior: result.storageBehavior,
    );

    return true;
  }

  Future<void> _handleTrackRequestSubmitted() async {
    final AcademyTrack track = _selectedTrack;

    late final AcademyRequestSubmissionResult result;

    try {
      result = await _requestRepository.submitTrackRequest(
        trackTitle: track.title,
        trackId: track.id,
      );
    } catch (_) {
      if (mounted) {
        AcademySnackbars.showRequestSubmissionFailed(context: context);
      }

      return;
    }

    if (!mounted) {
      return;
    }

    if (!result.isSuccessful) {
      _showUnsuccessfulSubmission(result);
      return;
    }

    setState(() {});

    AcademySnackbars.showTrackRequestSubmitted(
      context: context,
      trackTitle: result.request?.title ?? track.title,
      newRequestCount: _newAdminRequestCount,
      storageBehavior: result.storageBehavior,
    );
  }

  void _handleRequestReviewed(AcademyRequest request) {
    _handleAdminRequestAction(
      action: () => _requestRepository.markReviewed(request.id),
      message: AcademyRequestMessageBuilder.reviewed(request),
    );
  }

  void _handleRequestApproved(AcademyRequest request) {
    _handleAdminRequestAction(
      action: () => _requestRepository.approve(request.id),
      message: AcademyRequestMessageBuilder.approved(request),
    );
  }

  void _handleRequestDeclined(AcademyRequest request) {
    _handleAdminRequestAction(
      action: () => _requestRepository.decline(request.id),
      message: AcademyRequestMessageBuilder.declined(request),
    );
  }

  void _handleAdminRequestAction({
    required bool Function() action,
    required String message,
  }) {
    final bool changed = action();

    if (!changed) {
      AcademySnackbars.showAdminActionUnavailable(context: context);
      return;
    }

    setState(() {});

    AcademySnackbars.showAdminAction(context: context, message: message);
  }

  void _showUnsuccessfulSubmission(AcademyRequestSubmissionResult result) {
    if (result.isUnavailable) {
      AcademySnackbars.showRequestSubmissionUnavailable(context: context);
      return;
    }

    AcademySnackbars.showRequestSubmissionFailed(context: context);
  }
}
