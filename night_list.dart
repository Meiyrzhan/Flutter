import 'package:flutter/material.dart';

import '../models/game_night.dart';
import 'night_card.dart';

/// Phones get a ListView.separated, wide layouts a GridView.builder with
/// cells of at most 360 px. LayoutBuilder decides from the space this widget
/// is given, not from the whole screen.
class NightList extends StatelessWidget {
  const NightList({
    super.key,
    required this.nights,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<GameNight> nights;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<String> onFavourite;

  Widget _card(GameNight night) {
    return NightCard(
      night: night,
      onTap: () => onOpen(night),
      onFavourite: () => onFavourite(night.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 132,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: nights.length,
            itemBuilder: (context, index) => _card(nights[index]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
          itemCount: nights.length,
          itemBuilder: (context, index) => _card(nights[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        );
      },
    );
  }
}
