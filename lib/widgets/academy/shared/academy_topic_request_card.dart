import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_form_field.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';

class AcademyTopicRequestCard extends StatefulWidget {
  const AcademyTopicRequestCard({
    super.key,
    required this.onSubmit,
  });

  final ValueChanged<String> onSubmit;

  @override
  State<AcademyTopicRequestCard> createState() {
    return _AcademyTopicRequestCardState();
  }
}

class _AcademyTopicRequestCardState
    extends State<AcademyTopicRequestCard> {
  static const int _maxTopicLength = 80;

  final TextEditingController _topicController =
  TextEditingController();

  bool get _canSubmit {
    return _topicController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _topicController.addListener(
      _handleTopicChanged,
    );
  }

  @override
  void dispose() {
    _topicController.removeListener(
      _handleTopicChanged,
    );

    _topicController.dispose();

    super.dispose();
  }

  void _handleTopicChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _submitTopic() {
    final String topic =
    _topicController.text.trim();

    if (topic.isEmpty) {
      return;
    }

    widget.onSubmit(topic);

    _topicController.clear();

    FocusScope.of(context).unfocus();
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
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          AtlasFormField(
            controller: _topicController,
            label: 'Topic Request',
            hintText:
            'Example: Limited Edition stickers',
            icon: Icons.edit_note_rounded,
            maxLength: _maxTopicLength,
            textInputAction: TextInputAction.done,
            textCapitalization:
            TextCapitalization.sentences,
            onFieldSubmitted: (_) {
              if (_canSubmit) {
                _submitTopic();
              }
            },
            suffixIcon: IconButton(
              tooltip: 'Submit topic request',
              onPressed:
              _canSubmit ? _submitTopic : null,
              icon: const Icon(
                Icons.send_rounded,
              ),
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          const AtlasInfoBanner(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Review Queue',
            message:
            'Topic requests can be reviewed through the Atlas Academy admin request workflow.',
          ),
        ],
      ),
    );
  }
}