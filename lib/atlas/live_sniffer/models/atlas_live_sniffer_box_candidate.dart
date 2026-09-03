final class AtlasLiveSnifferBoxCandidate {
  const AtlasLiveSnifferBoxCandidate({
    required this.candidateId,
    required this.productNumber,
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.featuredScore,
  });

  final String candidateId;
  final String productNumber;
  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double featuredScore;

  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;
}
