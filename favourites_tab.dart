import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../utils/sorting.dart';
import '../widgets/empty_state.dart';
import '../widgets/night_list.dart';

/// Tab 2: only the favourites, same card, same list/grid rules.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.nights,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<GameNight> nights;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<String> onToggleFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = sortedByDate(nights.where((night) => night.favourite));
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse game nights',
        onAction: onBrowse,
      );
    }
    return NightList(
      nights: favourites,
      onOpen: onOpen,
      onFavourite: onToggleFavourite,
    );
  }
}
