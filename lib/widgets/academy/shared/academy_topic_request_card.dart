import 'package:flutter/material.dart';

import '../../../academy/models/academy_request_submission_result.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_form_field.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';

class AcademyTopicRequestCard extends StatefulWidget {
  const AcademyTopicRequestCard({
    super.key,
    required this.storageBehavior,
    this.onSubmit,
  });

  final AcademyRequestStorageBehavior storageBehavior;
  final Future<bool> Function(String topic)? onSubmit;

  @override
  State<AcademyTopicRequestCard> createState() {
    return _AcademyTopicRequestCardState();
  }
}

class _AcademyTopicRequestCardState extends State<AcademyTopicRequestCard> {
  static const int _maxTopicLength = 80;

  final TextEditingController _topicController = TextEditingController();

  bool _isSubmitting = false;

  bool get _isSubmissionAvailable {
    return widget.storageBehavior !=
            AcademyRequestStorageBehavior.unavailable &&
        widget.onSubmit != null;
  }

  bool get _canSubmit {
    return _isSubmissionAvailable &&
        !_isSubmitting &&
        _topicController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _topicController.addListener(_handleTopicChanged);
  }

  @override
  void dispose() {
    _topicController.removeListener(_handleTopicChanged);

    _topicController.dispose();

    super.dispose();
  }

  void _handleTopicChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _submitTopic() async {
    final String topic = _topicController.text.trim();

    final Future<bool> Function(String topic)? onSubmit = widget.onSubmit;

    if (topic.isEmpty || !_canSubmit || onSubmit == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    bool submitted = false;

    try {
      submitted = await onSubmit(topic);
    } catch (_) {
      submitted = false;
    }

    if (!mounted) {
      return;
    }

    if (submitted) {
      _topicController.clear();

      FocusScope.of(context).unfocus();
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Suggest an Academy Topic',
            subtitle:
                'Want Atlas to teach something else? Suggest a collector topic for future Academy review.',
            icon: Icons.lightbulb_outline_rounded,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasFormField(
            controller: _topicController,
            enabled: _isSubmissionAvailable && !_isSubmitting,
            label: 'Topic Request',
            hintText: 'Example: Limited Edition stickers',
            icon: Icons.edit_note_rounded,
            maxLength: _maxTopicLength,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onFieldSubmitted: (_) {
              if (_canSubmit) {
                _submitTopic();
              }
            },
            suffixIcon: IconButton(
              tooltip: 'Submit topic request',
              onPressed: _canSubmit ? _submitTopic : null,
              icon: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasInfoBanner(
            icon: _isSubmissionAvailable
                ? Icons.developer_mode_rounded
                : Icons.cloud_off_rounded,
            title: _isSubmissionAvailable
                ? widget.storageBehavior ==
                          AcademyRequestStorageBehavior.sessionOnly
                      ? 'Local Developer Queue'
                      : 'Review Queue'
                : 'Requests Unavailable',
            message: _isSubmissionAvailable
                ? widget.storageBehavior ==
                          AcademyRequestStorageBehavior.sessionOnly
                      ? 'Requests are saved only for this debug session and are lost when the session ends.'
                      : 'Submitted topics are sent to the Atlas Academy review queue.'
                : 'Topic requests will be enabled when durable request storage is connected.',
          ),
        ],
      ),
    );
  }
}
