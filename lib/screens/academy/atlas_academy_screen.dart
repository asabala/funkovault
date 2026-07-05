import 'package:flutter/material.dart';

import '../../academy/repository/academy_repository.dart';
import '../../widgets/academy/academy_category_card.dart';
import 'academy_category_screen.dart';

class AtlasAcademyScreen extends StatelessWidget {
  const AtlasAcademyScreen({super.key});

  static const _repository = AcademyRepository();

  @override
  Widget build(BuildContext context) {
    final categories = _repository.getCategoriesForTrack('Funko Collecting');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Academy'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text(
            'Become a smarter collector.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Learn collector terms, variants, stickers, figure types, values, and collecting tips directly inside Atlas.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFD6B25E).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFD6B25E).withValues(alpha: 0.22),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  '🎓',
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'First track: Funko Collecting',
                    style: TextStyle(
                      color: Color(0xFFD6B25E),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final category in categories) ...[
            AcademyCategoryCard(
              category: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcademyCategoryScreen(
                      category: category,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}