import '../authenticity/models/atlas_authenticity_assessment.dart';
import 'abstract_intelligence_contribution.dart';
import 'contribution_category.dart';

final class AuthenticityContribution extends AbstractIntelligenceContribution {
  AuthenticityContribution({
    required super.contributionId,
    required super.sourceEngineId,
    required super.createdAt,
    required this.assessment,
    super.confidence,
    super.attributes,
  });

  final AtlasAuthenticityAssessment assessment;

  @override
  ContributionCategory get category => ContributionCategory.authenticity;
}
