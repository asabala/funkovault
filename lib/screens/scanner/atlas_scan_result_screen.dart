import 'package:flutter/material.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';

class AtlasScanResultScreen extends StatelessWidget {
  final ScanSession session;

  const AtlasScanResultScreen({
    required this.session,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ScanCode? primaryCode =
        session.bestCandidate ?? _firstDetectedCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Result',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: primaryCode == null
              ? const _NoBarcodeView()
              : _BarcodeResultView(
            session: session,
            code: primaryCode,
          ),
        ),
      ),
    );
  }

  ScanCode? get _firstDetectedCode {
    if (session.detectedCodes.isEmpty) {
      return null;
    }

    return session.detectedCodes.first;
  }
}

class _NoBarcodeView extends StatelessWidget {
  const _NoBarcodeView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 72,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'No Barcode Detected',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Atlas could not find usable barcode evidence in this scan session.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.qr_code_scanner,
                ),
                label: const Text(
                  'Scan Again',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodeResultView extends StatelessWidget {
  final ScanSession session;
  final ScanCode code;

  const _BarcodeResultView({
    required this.session,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.qr_code_2_rounded,
            size: 72,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            code.isProductBarcode
                ? 'Barcode Detected'
                : 'Code Detected',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            code.isValid
                ? 'Atlas validated the scanned code and added it to the scan session.'
                : 'Atlas detected the code, but it did not pass validation.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 24,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _ResultRow(
                    label: 'Barcode',
                    value: code.normalizedValue,
                    selectable: true,
                  ),
                  const Divider(),
                  _ResultRow(
                    label: 'Format',
                    value: _formatLabel(code.format),
                  ),
                  const Divider(),
                  _ResultRow(
                    label: 'Source',
                    value: _sourceLabel(code.source),
                  ),
                  const Divider(),
                  _ResultRow(
                    label: 'Validation',
                    value: code.isValid
                        ? 'Passed'
                        : 'Failed',
                  ),
                  const Divider(),
                  _ResultRow(
                    label: 'Evidence',
                    value:
                    '${session.contributionCount} contribution${session.contributionCount == 1 ? '' : 's'}',
                  ),
                  const Divider(),
                  _ResultRow(
                    label: 'Session Status',
                    value: _statusLabel(
                      session.status,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (session.warnings.isNotEmpty) ...[
            const SizedBox(
              height: 16,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Scan Warnings',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    for (final String warning
                    in session.warnings)
                      Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: Text(warning),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(
            height: 24,
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.qr_code_scanner,
            ),
            label: const Text(
              'Scan Again',
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(
      ScanCodeFormat format,
      ) {
    switch (format) {
      case ScanCodeFormat.upcA:
        return 'UPC-A';
      case ScanCodeFormat.upcE:
        return 'UPC-E';
      case ScanCodeFormat.ean8:
        return 'EAN-8';
      case ScanCodeFormat.ean13:
        return 'EAN-13';
      case ScanCodeFormat.qrCode:
        return 'QR Code';
      case ScanCodeFormat.unknown:
        return 'Unknown';
    }
  }

  String _sourceLabel(
      ScanCodeSource source,
      ) {
    switch (source) {
      case ScanCodeSource.camera:
        return 'Camera';
      case ScanCodeSource.manualEntry:
        return 'Manual Entry';
      case ScanCodeSource.importedData:
        return 'Imported Data';
      case ScanCodeSource.externalProvider:
        return 'External Provider';
    }
  }

  String _statusLabel(
      ScanSessionStatus status,
      ) {
    switch (status) {
      case ScanSessionStatus.created:
        return 'Created';
      case ScanSessionStatus.scanning:
        return 'Scanning';
      case ScanSessionStatus.analyzing:
        return 'Analyzing';
      case ScanSessionStatus.resolving:
        return 'Resolving';
      case ScanSessionStatus.awaitingConfirmation:
        return 'Awaiting Confirmation';
      case ScanSessionStatus.completed:
        return 'Completed';
      case ScanSessionStatus.cancelled:
        return 'Cancelled';
      case ScanSessionStatus.failed:
        return 'Failed';
    }
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool selectable;

  const _ResultRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: selectable
                ? SelectableText(value)
                : Text(value),
          ),
        ],
      ),
    );
  }
}