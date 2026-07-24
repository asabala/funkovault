import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../widgets/vault/atlas_evidence_card.dart';
import '../../widgets/atlas/atlas_greeting_card.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import '../engines/intelligence/atlas_confidence_engine.dart';
import '../repositories/vault_repository.dart';

class AtlasConfidenceScreen extends StatelessWidget {
  const AtlasConfidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();
    const confidenceEngine = AtlasConfidenceEngine();

    final pops = repository.allPops(appState);
    final confidence = confidenceEngine.calculate(pops);

    final missingValues =
        pops.where((pop) => pop.value <= 0).length;
    final missingPricePaid =
        pops.where((pop) => pop.pricePaid <= 0).length;
    final missingImages =
        pops.where((pop) => pop.imageUrl.isEmpty).length;
    final commonVariants =
        pops.where((pop) => pop.variant == 'Common').length;
    final noRetailExclusive =
        pops.where((pop) => pop.retailExclusive == 'None').length;
    final noEventSticker =
        pops.where((pop) => pop.eventSticker == 'None').length;
    final unsigned =
        pops.where((pop) => pop.signature == 'Unsigned').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Confidence'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGreetingCard(
            title:
            'Atlas Confidence ${confidence.score.toStringAsFixed(0)}%',
            message: confidence.message,
            icon: Icons.psychology,
          ),

          const SizedBox(height: 24),

          AtlasEvidenceCard(
            title: 'Confidence Evidence',
            evidence: [
              '$missingValues Pops are missing estimated values.',
              '$missingPricePaid Pops are missing purchase prices.',
              '$missingImages Pops are missing images.',
              '$commonVariants Pops are marked as Common.',
              '$noRetailExclusive Pops have no retail exclusive selected.',
              '$noEventSticker Pops have no event sticker selected.',
              '$unsigned Pops are unsigned.',
            ],
          ),
        ],
      ),
    );
  }
}