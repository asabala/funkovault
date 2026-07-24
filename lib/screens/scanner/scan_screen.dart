import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:funkovault2/atlas/scan/engine/barcode_intelligence_engine.dart';
import 'package:funkovault2/atlas/scan/engine/engine_context.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/atlas/scan/pipeline/standard_scan_pipeline.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/scanner/atlas_scan_result_screen.dart';
import 'package:funkovault2/services/funko_catalog_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() {
    return _ScanScreenState();
  }
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _scannerController =
  MobileScannerController(
    formats: const <BarcodeFormat>[
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.qrCode,
    ],
  );

  String? _scannedCode;
  bool _isProcessing = false;
  int _catalogCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    final catalog =
    await FunkoCatalogService.loadCatalog();

    if (!mounted) {
      return;
    }

    setState(() {
      _catalogCount = catalog.length;
    });
  }

  Future<void> _handleDetection(
      BarcodeCapture capture,
      ) async {
    if (_isProcessing) {
      return;
    }

    final Barcode? barcode =
    _firstUsableBarcode(capture);

    if (barcode == null) {
      return;
    }

    final String rawValue =
        barcode.rawValue?.trim() ?? '';

    if (rawValue.isEmpty) {
      return;
    }

    final ScanCodeFormat format =
    _mapBarcodeFormat(barcode.format);

    final ScanCode scanCode = ScanCode(
      rawValue: rawValue,
      normalizedValue:
      _normalizeCodeValue(rawValue),
      format: format,
      source: ScanCodeSource.camera,
      capturedAt: DateTime.now().toUtc(),
      isValid:
      format != ScanCodeFormat.unknown,
      confidence: 1.0,
    );

    setState(() {
      _isProcessing = true;
      _scannedCode =
          scanCode.normalizedValue;
    });

    await _scannerController.stop();

    try {
      final DateTime startedAt =
      DateTime.now().toUtc();

      final String executionId =
      _createExecutionId(
        startedAt,
        scanCode.normalizedValue,
      );

      final EngineContext engineContext = EngineContext(
        requestId: executionId,
        createdAt: startedAt,
        connectivity:
        EngineConnectivity.unknown,
        deviceType:
        EngineDeviceType.mobile,
        deviceCapabilities: const <String>{
          BarcodeIntelligenceEngine
              .capabilityId,
        },
        attributes: <String, Object?>{
          'scanSource':
          ScanCodeSource.camera.name,
          'scannerType':
          ScannerType.mobileScanner.name,
          'barcodeFormat':
          scanCode.format.name,
        },
      );

      final ScanSession initialSession =
      ScanSession(
        sessionId: executionId,
        startedAt: startedAt,
        status:
        ScanSessionStatus.analyzing,
        intent:
        ScanIntent.identifyProduct,
        performanceMode:
        ScanPerformanceMode
            .fastBarcodeOnly,
        scannerType:
        ScannerType.mobileScanner,
        detectedCodes: <ScanCode>[
          scanCode,
        ],
        bestCandidate: scanCode,
      );

      final pipeline = StandardScanPipeline.create(
        engineContext,
      );

      final result = await pipeline.process(
        initialSession,
        engineContext,
      );

      final ScanSession finalSession =
          result.finalSession;

      if (!mounted) {
        return;
      }

      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) {
            return AtlasScanResultScreen(
              session: finalSession,
            );
          },
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Atlas could not process this scan: $error',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        await _scannerController.start();
      }
    }
  }

  Barcode? _firstUsableBarcode(
      BarcodeCapture capture,
      ) {
    for (final Barcode barcode
    in capture.barcodes) {
      final String value =
          barcode.rawValue?.trim() ?? '';

      if (value.isNotEmpty) {
        return barcode;
      }
    }

    return null;
  }

  String _normalizeCodeValue(
      String rawValue,
      ) {
    return rawValue.trim();
  }

  ScanCodeFormat _mapBarcodeFormat(
      BarcodeFormat format,
      ) {
    switch (format) {
      case BarcodeFormat.upcA:
        return ScanCodeFormat.upcA;

      case BarcodeFormat.upcE:
        return ScanCodeFormat.upcE;

      case BarcodeFormat.ean8:
        return ScanCodeFormat.ean8;

      case BarcodeFormat.ean13:
        return ScanCodeFormat.ean13;

      case BarcodeFormat.qrCode:
        return ScanCodeFormat.qrCode;

      default:
        return ScanCodeFormat.unknown;
    }
  }

  String _createExecutionId(
      DateTime createdAt,
      String code,
      ) {
    final int codeHash =
    code.hashCode.abs();

    return 'scan_'
        '${createdAt.microsecondsSinceEpoch}_'
        '$codeHash';
  }

  Future<void> _openCatalog() async {
    if (_isProcessing) {
      return;
    }

    await _scannerController.stop();

    if (!mounted) {
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return const FunkoCatalogScreen();
        },
      ),
    );

    if (mounted) {
      await _scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Pop',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller:
                  _scannerController,
                  onDetect:
                  _handleDetection,
                ),
                const _ScannerGuide(),
                if (_isProcessing)
                  const _ProcessingOverlay(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding:
              const EdgeInsets.all(12),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    'Catalog Loaded: '
                        '$_catalogCount Pops',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child:
                    ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : _openCatalog,
                      icon: const Icon(
                        Icons.search,
                      ),
                      label: const Text(
                        'Browse Catalog',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    _isProcessing
                        ? 'Atlas is analyzing the scan...'
                        : _scannedCode ??
                        'Waiting for scan...',
                    textAlign:
                    TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerGuide extends StatelessWidget {
  const _ScannerGuide();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280,
          height: 170,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ProcessingOverlay
    extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Atlas is analyzing...',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                const Text(
                  'Validating scan evidence',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}