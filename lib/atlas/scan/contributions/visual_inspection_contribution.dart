import '../authenticity/models/atlas_visual_inspection.dart';
import 'abstract_intelligence_contribution.dart';
import 'contribution_category.dart';

final class VisualInspectionContribution
    extends AbstractIntelligenceContribution {
  VisualInspectionContribution({
    required super.contributionId,
    required super.sourceEngineId,
    required super.createdAt,
    required this.inspection,
    super.confidence,
    super.attributes,
  });

  final AtlasVisualInspection inspection;

  @override
  ContributionCategory get category => ContributionCategory.authenticity;
}
