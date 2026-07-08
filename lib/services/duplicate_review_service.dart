import '../models/pop.dart';

class DuplicateReviewService {
  const DuplicateReviewService();

  DuplicateReviewReport buildReport(List<Pop> pops) {
    final sameIdentityGroups = _findGroups(
      pops: pops,
      keyBuilder: _exactDuplicateKey,
    );

    final possibleVariantGroups = _findPossibleVariantGroups(
      pops: pops,
      sameIdentityGroups: sameIdentityGroups,
    );

    return DuplicateReviewReport(
      sameIdentityGroups: sameIdentityGroups,
      possibleVariantGroups: possibleVariantGroups,
    );
  }

  List<DuplicateReviewGroup> _findGroups({
    required List<Pop> pops,
    required String Function(Pop pop) keyBuilder,
  }) {
    final groups = <String, List<Pop>>{};

    for (final pop in pops) {
      final key = keyBuilder(pop);

      if (key.trim().isEmpty) {
        continue;
      }

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(pop);
    }

    final duplicateGroups = groups.entries
        .where((entry) => entry.value.length > 1)
        .map(
          (entry) => DuplicateReviewGroup(
        key: entry.key,
        pops: entry.value,
      ),
    )
        .toList();

    duplicateGroups.sort(
          (a, b) => b.pops.length.compareTo(a.pops.length),
    );

    return duplicateGroups;
  }

  List<DuplicateReviewGroup> _findPossibleVariantGroups({
    required List<Pop> pops,
    required List<DuplicateReviewGroup> sameIdentityGroups,
  }) {
    final sameIdentityKeys = sameIdentityGroups
        .map(
          (group) => group.key,
    )
        .toSet();

    final looseGroups = _findGroups(
      pops: pops,
      keyBuilder: _looseReviewKey,
    );

    return looseGroups.where((group) {
      final uniqueIdentityKeys = group.pops
          .map(
        _exactDuplicateKey,
      )
          .toSet();

      final hasOnlyOneIdentityKey = uniqueIdentityKeys.length == 1;
      final isAlreadySameIdentityGroup = hasOnlyOneIdentityKey &&
          sameIdentityKeys.contains(uniqueIdentityKeys.first);

      return !isAlreadySameIdentityGroup;
    }).toList();
  }

  String _looseReviewKey(Pop pop) {
    return [
      pop.name,
      pop.number,
    ].map(_normalize).join('|');
  }

  String _exactDuplicateKey(Pop pop) {
    return pop.duplicateKey;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}

class DuplicateReviewReport {
  const DuplicateReviewReport({
    required this.sameIdentityGroups,
    required this.possibleVariantGroups,
  });

  final List<DuplicateReviewGroup> sameIdentityGroups;
  final List<DuplicateReviewGroup> possibleVariantGroups;

  int get totalGroups => sameIdentityGroups.length + possibleVariantGroups.length;

  bool get hasGroups => totalGroups > 0;
}

class DuplicateReviewGroup {
  const DuplicateReviewGroup({
    required this.key,
    required this.pops,
  });

  final String key;
  final List<Pop> pops;
}