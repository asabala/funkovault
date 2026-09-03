import 'dart:io';

import 'package:flutter/material.dart';

import '../../atlas/scan/acquisition/atlas_guided_inspection_capture_plan.dart';
import '../../atlas/scan/acquisition/atlas_inspection_image_capture_service.dart';
import '../../atlas/scan/authenticity/atlas_visual_inspection_service.dart';
import '../../atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import '../../atlas/scan/models/scan_image.dart';
import '../../atlas/scan/models/scan_session.dart';
import '../../atlas/scan/recognition/atlas_text_recognition_service.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_expandable_section.dart';
import '../../widgets/atlas/components/atlas_form_field.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/scanner/atlas_authenticity_card.dart';
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
        if (recognizedText.isNotEmpty && textTarget != null) {
          textTarget.text = recognizedText;
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

  @override
  Widget build(BuildContext context) {
    final List<ScanImage> localPreviewImages = _images
        .where((ScanImage image) => image.hasLocalPath)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Visual Inspection')),
      body: VaultScrollView(
        children: [
          const AtlasInfoBanner(
            title: 'Evidence, not certification',
            message:
                'Atlas records inspection evidence and warning signals. It does not certify an item as authentic or fake.',
            icon: Icons.info_outline_rounded,
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
          AtlasExpandableSection(
            title: AtlasGuidedInspectionStep.packagingCopyright.title,
            icon: Icons.text_fields_rounded,
            initiallyExpanded: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AtlasGuidedInspectionStep.packagingCopyright.guidance),
                const SizedBox(height: AtlasSpacing.md),
                AtlasFormField(
                  controller: _copyright,
                  label: 'Copyright Text / Year',
                  icon: Icons.copyright_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                _captureButton(
                  AtlasGuidedInspectionStep.packagingCopyright,
                  textTarget: _copyright,
                ),
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
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasExpandableSection(
            title: '✍️ Autograph & 📜 COA Evidence',
            icon: Icons.draw_outlined,
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
                _captureButton(AtlasGuidedInspectionStep.autograph),
                const SizedBox(height: AtlasSpacing.md),
                AtlasFormField(
                  controller: _signature,
                  label: 'Signature / Signer',
                  icon: Icons.draw_outlined,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                _check('COA is present', _coa, (bool? value) => _coa = value),
                const SizedBox(height: AtlasSpacing.sm),
                _captureButton(AtlasGuidedInspectionStep.coa),
                const SizedBox(height: AtlasSpacing.md),
                AtlasFormField(
                  controller: _provider,
                  label: 'Authentication Provider',
                  icon: Icons.verified_outlined,
                ),
                const SizedBox(height: AtlasSpacing.md),
                AtlasFormField(
                  controller: _number,
                  label: 'Authenticity Number',
                  icon: Icons.numbers_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasFormField(
            controller: _notes,
            label: 'Inspection Notes',
            icon: Icons.notes_rounded,
            maxLines: 4,
          ),
          if (localPreviewImages.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: localPreviewImages.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AtlasSpacing.sm),
                itemBuilder: (_, int index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(localPreviewImages[index].localPath!),
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
          if (_preview?.authenticityContribution != null) ...[
            const SizedBox(height: AtlasSpacing.lg),
            AtlasAuthenticityCard(
              assessment: _preview!.authenticityContribution!.assessment,
            ),
          ],
          const SizedBox(height: AtlasSpacing.lg),
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

  Widget _captureOnlySection(AtlasGuidedInspectionStep step) {
    return AtlasExpandableSection(
      title: step.title,
      icon: Icons.center_focus_strong_rounded,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(step.guidance),
          const SizedBox(height: AtlasSpacing.md),
          _captureButton(step),
        ],
      ),
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
      icon: Icons.center_focus_strong_rounded,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(step.guidance),
          const SizedBox(height: AtlasSpacing.md),
          AtlasFormField(
            controller: controller,
            label: label,
            icon: Icons.text_snippet_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          _captureButton(step, textTarget: controller),
          ...checks,
        ],
      ),
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
    return DropdownButtonFormField<bool?>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: const [
        DropdownMenuItem<bool?>(value: null, child: Text('Not inspected')),
        DropdownMenuItem<bool?>(value: true, child: Text('Yes')),
        DropdownMenuItem<bool?>(value: false, child: Text('No / warning seen')),
      ],
      onChanged: (bool? next) => setState(() => update(next)),
    );
  }
}
