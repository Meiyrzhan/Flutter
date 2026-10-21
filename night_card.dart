import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../utils/format.dart';

/// The one reusable card: avatar (with badge) on the left, text in the
/// middle, favourite button on the right.
class NightCard extends StatelessWidget {
  const NightCard({
    super.key,
    required this.night,
    required this.onTap,
    required this.onFavourite,
  });

  final GameNight night;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final category = night.category;
    final (:taken, :free) = night.places;
    final String? badge =
        night.isFull ? 'FULL' : (free <= 5 ? '$free left' : null);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: category.colorOf(scheme),
                      child: Icon(
                        category.icon,
                        color: category.onColorOf(scheme),
                      ),
                    ),
                    if (badge case final label?)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -8,
                        child: Center(
                          child: _Badge(label: label, isFull: night.isFull),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      night.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDate(night.startsAt)} · $taken/${night.seats}',
                      style: text.bodySmall,
                    ),
                    Text(
                      night.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: night.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onFavourite,
                icon: Icon(
                  night.favourite ? Icons.favorite : Icons.favorite_border,
                  color: night.favourite ? scheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.isFull});

  final String label;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFull ? scheme.error : scheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isFull ? scheme.onError : scheme.onTertiary,
          ),
        ),
      ),
    );
  }
}
