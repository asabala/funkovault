import 'dart:io';

import 'package:flutter/material.dart';

import '../../atlas/scan/acquisition/atlas_guided_inspection_capture_plan.dart';
import '../../atlas/scan/acquisition/atlas_inspection_image_capture_service.dart';
import '../../atlas/scan/authenticity/atlas_visual_inspection_service.dart';
import '../../atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import '../../atlas/scan/authenticity/providers/atlas_authentication_evidence_interpreter.dart';
import '../../atlas/scan/models/scan_image.dart';
import '../../atlas/scan/models/scan_session.dart';
import '../../atlas/scan/recognition/atlas_text_recognition_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_expandable_section.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_form_field.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/scanner/atlas_authenticity_card.dart';
import '../../widgets/scanner/atlas_inspection_intelligence_dashboard.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class AtlasVisualInspectionScreen extends StatefulWidget {
  const AtlasVisualInspectionScreen({
    super.key,
    required this.session,
    this.imageCapture,
    this.textRecognition,
    this.inspectionService = const AtlasVisualInspectionService(),
  });

  final ScanSession session;
  final AtlasInspectionImageCapture? imageCapture;
  final AtlasTextRecognition? textRecognition;
  final AtlasVisualInspectionService inspectionService;

  @override
  State<AtlasVisualInspectionScreen> createState() =>
      _AtlasVisualInspectionScreenState();
}

class _AtlasVisualInspectionScreenState
    extends State<AtlasVisualInspectionScreen> {
  final _sticker = TextEditingController();
  final _stamp = TextEditingController();
  final _copyright = TextEditingController();
  final _signature = TextEditingController();
  final _provider = TextEditingController();
  final _number = TextEditingController();
  final _certificationText = TextEditingController();
  final _notes = TextEditingController();

  late final AtlasInspectionImageCapture _capture;
  late final AtlasTextRecognition _recognizer;

  final List<ScanImage> _images = <ScanImage>[];
  bool? _typography;
  bool? _border;
  bool? _printClear;
  bool? _cutEven;
  bool? _autograph;
  bool? _coa;
  bool _busy = false;
  ScanSession? _preview;

  @override
  void initState() {
    super.initState();
    _capture = widget.imageCapture ?? AtlasInspectionImageCaptureService();
    _recognizer = widget.textRecognition ?? AtlasTextRecognitionService();

    final existing = widget.session.visualInspectionContribution?.inspection;
    if (existing != null) {
      _sticker.text = existing.stickerText;
      _stamp.text = existing.productionStampText;
      _copyright.text = existing.copyrightText;
      _signature.text = existing.signature;
      _provider.text = existing.authenticationProvider;
      _number.text = existing.authenticityNumber;
      _certificationText.text = existing.certificationText;
      _notes.text = existing.notes;
      _images.addAll(existing.images);
      _typography = existing.typographyConsistent;
      _border = existing.borderConsistent;
      _printClear = existing.stickerPrintClear;
      _cutEven = existing.stickerCutEven;
      _autograph = existing.hasAutograph;
      _coa = existing.hasCoa;
    }

    if (widget.session.authenticityContribution != null) {
      _preview = widget.session;
    }
  }

  @override
  void dispose() {
    _sticker.dispose();
    _stamp.dispose();
    _copyright.dispose();
    _signature.dispose();
    _provider.dispose();
    _number.dispose();
    _certificationText.dispose();
    _notes.dispose();
    _recognizer.close();
    super.dispose();
  }

  Future<void> _captureStep(
    AtlasGuidedInspectionStep step, {
    TextEditingController? textTarget,
  }) async {
    final source = await showModalBottomSheet<AtlasInspectionImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () =>
                  Navigator.pop(context, AtlasInspectionImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () =>
                  Navigator.pop(context, AtlasInspectionImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _busy = true);
    try {
      final ScanImage? image = await _capture.capture(
        source: source,
        type: step.imageType,
      );
      if (image == null) return;

      String recognizedText = '';
      if (step.supportsTextRecognition &&
          textTarget != null &&
          image.hasLocalPath) {
        recognizedText = await _recognizer.recognize(image.localPath!);
      }

      if (!mounted) return;
      setState(() {
        _images.removeWhere((ScanImage item) => item.type == step.imageType);
        _images.add(image);
        _preview = null;

        if (recognizedText.isNotEmpty && textTarget != null) {
          textTarget.text = recognizedText;
          if (step == AtlasGuidedInspectionStep.coa) {
            final interpretation =
                AtlasAuthenticationEvidenceInterpreter.interpret(
                  provider: _provider.text,
                  certificateNumber: _number.text,
                  certificationText: recognizedText,
                  hasCoa: _coa,
                );
            if (_provider.text.trim().isEmpty &&
                interpretation.detectedProviderDisplayName.isNotEmpty) {
              _provider.text = interpretation.detectedProviderDisplayName;
            }
            if (_number.text.trim().isEmpty &&
                interpretation.detectedCertificateNumber.isNotEmpty) {
              _number.text = interpretation.detectedCertificateNumber;
            }
          }
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  AtlasVisualInspection _inspection() => AtlasVisualInspection(
    stickerText: _sticker.text,
    productionStampText: _stamp.text,
    copyrightText: _copyright.text,
    signature: _signature.text,
    authenticationProvider: _provider.text,
    authenticityNumber: _number.text,
    certificationText: _certificationText.text,
    typographyConsistent: _typography,
    borderConsistent: _border,
    stickerPrintClear: _printClear,
    stickerCutEven: _cutEven,
    hasAutograph: _autograph,
    hasCoa: _coa,
    notes: _notes.text,
    images: _images,
  );

  Future<void> _analyze({required bool finish}) async {
    setState(() => _busy = true);
    try {
      final ScanSession session = await widget.inspectionService.inspect(
        session: widget.session,
        inspection: _inspection(),
      );

      if (!mounted) return;
      if (finish) {
        Navigator.pop(context, session);
      } else {
        setState(() => _preview = session);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _hasImage(AtlasGuidedInspectionStep step) {
    return _images.any((ScanImage image) => image.type == step.imageType);
  }

  ScanSession get _displaySession => _preview ?? widget.session;

  @override
  Widget build(BuildContext context) {
    final List<ScanImage> localPreviewImages = _images
        .where((ScanImage image) => image.hasLocalPath)
        .toList(growable: false);
    final AtlasVisualInspection draft = _inspection();

    return Scaffold(
      appBar: AppBar(title: const Text('Visual Inspection')),
      body: VaultScrollView(
        children: [
          _inspectionHero(draft),
          const SizedBox(height: AtlasSpacing.lg),
          const AtlasInfoBanner(
            title: 'Evidence, not certification',
            message:
                'Atlas records inspection evidence and warning signals. It does not certify an item as authentic or fake.',
            icon: Icons.info_outline_rounded,
            accentColor: AtlasColors.intelligenceBlue,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _captureOnlySection(AtlasGuidedInspectionStep.frontBox),
          const SizedBox(height: AtlasSpacing.lg),
          _textCaptureSection(
            step: AtlasGuidedInspectionStep.stickerWindow,
            controller: _sticker,
            label: 'Sticker Text',
            checks: [
              _check(
                'Print is clear',
                _printClear,
                (bool? value) => _printClear = value,
              ),
              _check(
                'Cut and border are even',
                _cutEven,
                (bool? value) => _cutEven = value,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _textCaptureSection(
            step: AtlasGuidedInspectionStep.bottomStamp,
            controller: _stamp,
            label: 'Production Code (JJL/FAC)',
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _packagingSection(),
          const SizedBox(height: AtlasSpacing.lg),
          _autographSection(),
          const SizedBox(height: AtlasSpacing.lg),
          _coaSection(),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasFormField(
            controller: _notes,
            label: 'Inspection Notes',
            icon: Icons.notes_rounded,
            maxLines: 4,
            onChanged: (_) => setState(() => _preview = null),
          ),
          if (localPreviewImages.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            _evidenceStrip(localPreviewImages),
          ],
          const SizedBox(height: AtlasSpacing.xl),
          const AtlasSectionHeader(
            title: 'Atlas Inspection Intelligence',
            subtitle:
                'Five separate signals keep evidence quality, reference strength, concern, variant state, and autograph documentation distinct.',
            icon: Icons.auto_awesome_rounded,
            accentColor: AtlasColors.intelligenceBlue,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasInspectionIntelligenceDashboard(
            session: _displaySession,
            inspection: draft,
          ),
          if (_preview?.authenticityContribution != null) ...[
            const SizedBox(height: AtlasSpacing.lg),
            AtlasAuthenticityCard(
              assessment: _preview!.authenticityContribution!.assessment,
            ),
          ],
          const SizedBox(height: AtlasSpacing.xl),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _analyze(finish: false),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('🧠 Preview Assessment'),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          FilledButton.icon(
            onPressed: _busy ? null : () => _analyze(finish: true),
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: const Text('Save Inspection'),
          ),
        ],
      ),
    );
  }

  Widget _inspectionHero(AtlasVisualInspection draft) {
    final int captured = AtlasGuidedInspectionCapturePlan.steps
        .where(_hasImage)
        .length;
    final int inspected = draft.inspectedAreas.length;
    final double progress =
        inspected / AtlasGuidedInspectionCapturePlan.steps.length;

    return AtlasGlassCard(
      accentColor: AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: '🔎 Guided Visual Inspection',
            subtitle:
                'Capture only the evidence available for this item. Missing evidence is never treated as counterfeit evidence.',
            icon: Icons.document_scanner_outlined,
            accentColor: AtlasColors.intelligenceBlue,
            trailing: AtlasStatusChip(
              label: '$inspected / 6 inspected',
              icon: Icons.fact_check_outlined,
              accentColor: AtlasColors.intelligenceBlue,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 10,
              backgroundColor: AtlasColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AtlasColors.intelligenceBlue,
              ),
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            '$captured of 6 guided images captured',
            style: AtlasTypography.bodySmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: AtlasGuidedInspectionCapturePlan.steps
                .map((step) => _stepChip(step))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _stepChip(AtlasGuidedInspectionStep step) {
    final _InspectionStepState state = _stepState(step);
    return AtlasStatusChip(
      label: '${_shortStepTitle(step)} • ${state.label}',
      icon: state.icon,
      accentColor: state.color,
    );
  }

  _InspectionStepState _stepState(AtlasGuidedInspectionStep step) {
    final assessment = _preview?.authenticityContribution?.assessment;
    final bool hasDiscrepancy =
        assessment?.evaluatedSignals.any(
          (signal) =>
              signal.area == step.inspectionArea && signal.isDiscrepancy,
        ) ??
        false;

    if (hasDiscrepancy) {
      return const _InspectionStepState(
        'Needs attention',
        Icons.warning_amber_rounded,
        AtlasColors.warning,
      );
    }

    final bool hasArea = _inspection().inspectedAreas.contains(
      step.inspectionArea,
    );
    if (_preview != null && hasArea) {
      return const _InspectionStepState(
        'Reviewed',
        Icons.task_alt_rounded,
        AtlasColors.success,
      );
    }
    if (hasArea || _hasImage(step)) {
      return const _InspectionStepState(
        'Captured',
        Icons.photo_camera_back_outlined,
        AtlasColors.intelligenceBlue,
      );
    }
    return const _InspectionStepState(
      'Not inspected',
      Icons.radio_button_unchecked_rounded,
      AtlasColors.textSecondary,
    );
  }

  Widget _captureOnlySection(AtlasGuidedInspectionStep step) {
    return AtlasExpandableSection(
      title: step.title,
      subtitle: step.guidance,
      icon: Icons.center_focus_strong_rounded,
      badge: _sectionBadge(step),
      accentColor: _stepState(step).color,
      initiallyExpanded: true,
      child: _captureButton(step),
    );
  }

  Widget _textCaptureSection({
    required AtlasGuidedInspectionStep step,
    required TextEditingController controller,
    required String label,
    List<Widget> checks = const <Widget>[],
  }) {
    return AtlasExpandableSection(
      title: step.title,
      subtitle: step.guidance,
      icon: Icons.center_focus_strong_rounded,
      badge: _sectionBadge(step),
      accentColor: _stepState(step).color,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasFormField(
            controller: controller,
            label: label,
            icon: Icons.text_snippet_outlined,
            maxLines: 3,
            onChanged: (_) => setState(() => _preview = null),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          _captureButton(step, textTarget: controller),
          ...checks,
        ],
      ),
    );
  }

  Widget _packagingSection() {
    final step = AtlasGuidedInspectionStep.packagingCopyright;
    return AtlasExpandableSection(
      title: step.title,
      subtitle: step.guidance,
      icon: Icons.text_fields_rounded,
      badge: _sectionBadge(step),
      accentColor: _stepState(step).color,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasFormField(
            controller: _copyright,
            label: 'Copyright Text / Year',
            icon: Icons.copyright_rounded,
            maxLines: 3,
            onChanged: (_) => setState(() => _preview = null),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          _captureButton(step, textTarget: _copyright),
          _check(
            'Typography looks consistent',
            _typography,
            (bool? value) => _typography = value,
          ),
          _check(
            'Box borders look consistent',
            _border,
            (bool? value) => _border = value,
          ),
        ],
      ),
    );
  }

  Widget _autographSection() {
    final step = AtlasGuidedInspectionStep.autograph;
    return AtlasExpandableSection(
      title: step.title,
      subtitle: step.guidance,
      icon: Icons.draw_outlined,
      badge: _sectionBadge(step),
      accentColor: _stepState(step).color,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _check(
            'Autograph is present',
            _autograph,
            (bool? value) => _autograph = value,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          _captureButton(step),
          const SizedBox(height: AtlasSpacing.md),
          AtlasFormField(
            controller: _signature,
            label: 'Signature / Signer',
            icon: Icons.draw_outlined,
            onChanged: (_) => setState(() => _preview = null),
          ),
        ],
      ),
    );
  }

  Widget _coaSection() {
    final step = AtlasGuidedInspectionStep.coa;
    return AtlasExpandableSection(
      title: step.title,
      subtitle: step.guidance,
      icon: Icons.workspace_premium_outlined,
      badge: _sectionBadge(step),
      accentColor: _stepState(step).color,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _check('COA is present', _coa, (bool? value) => _coa = value),
          const SizedBox(height: AtlasSpacing.sm),
          _captureButton(step, textTarget: _certificationText),
          const SizedBox(height: AtlasSpacing.md),
          AtlasFormField(
            controller: _provider,
            label: 'Authentication Provider',
            icon: Icons.verified_outlined,
            onChanged: (_) => setState(() => _preview = null),
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasFormField(
            controller: _number,
            label: 'Authenticity Number',
            icon: Icons.numbers_rounded,
            onChanged: (_) => setState(() => _preview = null),
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasFormField(
            controller: _certificationText,
            label: 'Observed Certification Text',
            icon: Icons.document_scanner_outlined,
            maxLines: 4,
            onChanged: (_) => setState(() => _preview = null),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          AtlasGlassPanel(
            accentColor: AtlasColors.intelligenceBlue,
            child: Text(
              'OCR text is observational. Provider names and certificate numbers are not externally verified by Atlas.',
              style: AtlasTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionBadge(AtlasGuidedInspectionStep step) {
    final state = _stepState(step);
    return AtlasExpandableBadge(
      label: state.label,
      icon: state.icon,
      color: state.color,
    );
  }

  Widget _captureButton(
    AtlasGuidedInspectionStep step, {
    TextEditingController? textTarget,
  }) {
    final bool captured = _hasImage(step);
    return OutlinedButton.icon(
      onPressed: _busy
          ? null
          : () => _captureStep(step, textTarget: textTarget),
      icon: Icon(
        captured ? Icons.check_circle_outline : Icons.add_a_photo_outlined,
      ),
      label: Text(
        captured ? 'Captured — Replace Image' : 'Capture or Choose Image',
      ),
    );
  }

  Widget _check(String label, bool? value, ValueChanged<bool?> update) {
    return Padding(
      padding: const EdgeInsets.only(top: AtlasSpacing.sm),
      child: DropdownButtonFormField<bool?>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: const [
          DropdownMenuItem<bool?>(value: null, child: Text('Not inspected')),
          DropdownMenuItem<bool?>(value: true, child: Text('Yes')),
          DropdownMenuItem<bool?>(
            value: false,
            child: Text('No / warning seen'),
          ),
        ],
        onChanged: (bool? next) => setState(() {
          update(next);
          _preview = null;
        }),
      ),
    );
  }

  Widget _evidenceStrip(List<ScanImage> images) {
    return AtlasGlassCard(
      accentColor: AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AtlasSectionHeader(
            title: '📸 Captured Evidence',
            subtitle: 'Local previews for the current inspection session.',
            icon: Icons.photo_library_outlined,
            accentColor: AtlasColors.intelligenceBlue,
          ),
          const SizedBox(height: AtlasSpacing.md),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AtlasSpacing.sm),
              itemBuilder: (_, int index) => ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(images[index].localPath!),
                  width: 92,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortStepTitle(AtlasGuidedInspectionStep step) {
    return switch (step) {
      AtlasGuidedInspectionStep.frontBox => 'Front',
      AtlasGuidedInspectionStep.stickerWindow => 'Sticker',
      AtlasGuidedInspectionStep.bottomStamp => 'Stamp',
      AtlasGuidedInspectionStep.packagingCopyright => 'Packaging',
      AtlasGuidedInspectionStep.autograph => 'Autograph',
      AtlasGuidedInspectionStep.coa => 'COA',
    };
  }
}

class _InspectionStepState {
  const _InspectionStepState(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
