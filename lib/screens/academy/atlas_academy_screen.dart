import 'package:flutter/material.dart';

import '../../academy/academy_ids.dart';
import '../../academy/config/academy_admin_config.dart';
import '../../academy/config/academy_request_repository_provider.dart';
import '../../academy/data/academy_track_selector_items.dart';
import '../../academy/engines/academy_explainer_engine.dart';
import '../../academy/helpers/academy_request_message_builder.dart';
import '../../academy/helpers/ask_atlas_suggestions_builder.dart';
import '../../academy/models/academy_category.dart';
import '../../academy/models/academy_lesson.dart';
import '../../academy/models/academy_request.dart';
import '../../academy/models/academy_topic.dart';
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
  });

  @override
  State<AtlasAcademyScreen> createState() {
    return _AtlasAcademyScreenState();
  }
}

class _AtlasAcademyScreenState
    extends State<AtlasAcademyScreen> {
  static const AcademyRepository _repository =
  AcademyRepository();

  static const AcademyExplainerEngine _explainerEngine =
  AcademyExplainerEngine();

  final AcademyRequestRepositoryContract _requestRepository =
  AcademyRequestRepositoryProvider.create();

  String _selectedTrackId =
      AcademyTrackIds.funkoCollecting;

  List<AcademyRequest> get _adminRequests {
    return _requestRepository.getRequests();
  }

  int get _newAdminRequestCount {
    return _requestRepository.getNewRequestCount();
  }

  List<AcademyTrackSelectorItem> get _trackSelectorItems {
    return AcademyTrackSelectorItems.all;
  }

  AcademyTrackSelectorItem get _selectedTrack {
    return _trackSelectorItems.firstWhere(
          (track) => track.id == _selectedTrackId,
      orElse: () => _trackSelectorItems.first,
    );
  }

  bool get _isFunkoTrackSelected {
    return _selectedTrackId ==
        AcademyTrackIds.funkoCollecting;
  }

  bool get _shouldShowLocalAdminTools {
    return AcademyAdminConfig.showLocalAdminTools;
  }

  List<AcademyCategory> get _funkoCategories {
    return _repository.getCategoriesForTrack(
      AcademyTrackTitles.funkoCollecting,
    );
  }

  List<AcademyTopic> get _funkoRoadmapTopics {
    return _repository
        .getRoadmapTopicsForTrack(
      AcademyTrackIds.funkoCollecting,
    )
        .take(8)
        .toList(
      growable: false,
    );
  }

  List<String> get _askAtlasSuggestions {
    return AskAtlasSuggestionsBuilder.buildFunkoSuggestions(
      repository: _repository,
    );
  }

  int get _collectorBasicsLessonCount {
    return _repository
        .getLessonsForCategory(
      AcademyCategoryIds.funkoCollectorBasics,
    )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atlas Academy',
        ),
      ),
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
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          AcademyTrackSelectorCard(
            title: 'Choose Your Academy Track',
            subtitle:
            'Follow a learning path built around how collectors actually grow their vault.',
            tracks: _trackSelectorItems,
            selectedTrackId: _selectedTrackId,
            onTrackSelected:
            _handleTrackSelected,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          if (_isFunkoTrackSelected)
            FunkoAcademyTrackSection(
              categories: _funkoCategories,
              roadmapTopics:
              _funkoRoadmapTopics,
              askAtlasSuggestions:
              _askAtlasSuggestions,
              onAskAtlasQuestion:
              _handleAskAtlasQuestion,
              onOpenCategory:
              _openCategory,
              onTopicRequestSubmitted:
              _handleTopicRequestSubmitted,
              collectorBasicsLessonCount:
              _collectorBasicsLessonCount,
            )
          else
            AcademyComingSoonTrackSection(
              track: _selectedTrack,
              onNotifyTap:
              _handleTrackRequestSubmitted,
            ),
          if (_shouldShowLocalAdminTools) ...[
            const SizedBox(
              height: AtlasSpacing.lg,
            ),
            AcademyLocalAdminToolsSection(
              newRequestCount:
              _newAdminRequestCount,
              requests: _adminRequests,
              onReviewTap:
              _handleRequestReviewed,
              onApproveTap:
              _handleRequestApproved,
              onDeclineTap:
              _handleRequestDeclined,
            ),
          ],
        ],
      ),
    );
  }

  void _handleTrackSelected(
      String trackId,
      ) {
    final AcademyTrackSelectorItem selectedTrack =
    _trackSelectorItems.firstWhere(
          (track) => track.id == trackId,
      orElse: () => _trackSelectorItems.first,
    );

    if (_selectedTrackId != selectedTrack.id) {
      setState(() {
        _selectedTrackId =
            selectedTrack.id;
      });
    }

    if (!selectedTrack.isAvailable) {
      AcademySnackbars.showComingSoonTrack(
        context: context,
        trackTitle:
        selectedTrack.title,
      );
    }
  }

  void _handleAskAtlasQuestion(
      String question,
      ) {
    AskAtlasBottomSheetLauncher.show(
      context: context,
      question: question,
      repository: _repository,
      explainerEngine:
      _explainerEngine,
      onOpenLesson: _openLesson,
    );
  }

  void _openCategory(
      AcademyCategory category,
      ) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            AcademyCategoryScreen(
              category: category,
            ),
      ),
    );
  }

  void _openLesson(
      AcademyLesson lesson,
      ) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            AcademyLessonScreen(
              lesson: lesson,
            ),
      ),
    );
  }

  void _handleTopicRequestSubmitted(
      String topic,
      ) {
    final String cleanedTopic =
    topic.trim();

    if (cleanedTopic.isEmpty) {
      return;
    }

    setState(() {
      _requestRepository.addTopicRequest(
        topic: cleanedTopic,
        trackId:
        AcademyTrackIds.funkoCollecting,
      );
    });

    AcademySnackbars.showTopicRequestReceived(
      context: context,
      topic: cleanedTopic,
      newRequestCount:
      _newAdminRequestCount,
    );
  }

  void _handleTrackRequestSubmitted() {
    final AcademyTrackSelectorItem track =
        _selectedTrack;

    late final String requestTitle;

    setState(() {
      final AcademyRequest request =
      _requestRepository.addTrackRequest(
        trackTitle: track.title,
        trackId: track.id,
      );

      requestTitle = request.title;
    });

    AcademySnackbars.showTrackRequestReceived(
      context: context,
      trackTitle: requestTitle,
      newRequestCount:
      _newAdminRequestCount,
    );
  }

  void _handleRequestReviewed(
      AcademyRequest request,
      ) {
    _handleAdminRequestAction(
      action: () {
        _requestRepository.markReviewed(
          request.id,
        );
      },
      message:
      AcademyRequestMessageBuilder.reviewed(
        request,
      ),
    );
  }

  void _handleRequestApproved(
      AcademyRequest request,
      ) {
    _handleAdminRequestAction(
      action: () {
        _requestRepository.approve(
          request.id,
        );
      },
      message:
      AcademyRequestMessageBuilder.approved(
        request,
      ),
    );
  }

  void _handleRequestDeclined(
      AcademyRequest request,
      ) {
    _handleAdminRequestAction(
      action: () {
        _requestRepository.decline(
          request.id,
        );
      },
      message:
      AcademyRequestMessageBuilder.declined(
        request,
      ),
    );
  }

  void _handleAdminRequestAction({
    required VoidCallback action,
    required String message,
  }) {
    setState(action);

    AcademySnackbars.showAdminAction(
      context: context,
      message: message,
    );
  }
}