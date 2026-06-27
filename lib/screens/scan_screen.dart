import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/funko_catalog_service.dart';
import 'funko_catalog_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() =>
      _ScanScreenState();
}

class _ScanScreenState
    extends State<ScanScreen> {
  String? scannedCode;
  bool _hasScanned = false;
  int catalogCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final catalog =
    await FunkoCatalogService
        .loadCatalog();

    if (!mounted) return;

    setState(() {
      catalogCount = catalog.length;
    });
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
            child: MobileScanner(
              onDetect: (capture) {
                if (_hasScanned) {
                  return;
                }

                final barcode =
                    capture.barcodes.first;

                final code =
                    barcode.rawValue;

                if (code == null) {
                  return;
                }

                _hasScanned = true;

                setState(() {
                  scannedCode = code;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const FunkoCatalogScreen(),
                  ),
                ).then((_) {
                  if (mounted) {
                    _hasScanned = false;
                  }
                });
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Catalog Loaded: $catalogCount Pops',
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
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.search,
                      ),
                      label: const Text(
                        'Browse Catalog',
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const FunkoCatalogScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    scannedCode ??
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