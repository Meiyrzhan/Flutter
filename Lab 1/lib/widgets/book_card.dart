import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/format.dart';

/// R18: the one reusable card. Avatar with badge on the left, text in an
/// Expanded column, favourite button on the right.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final genreColor = book.genre.color(scheme);

    // R5: destructure the record where it is shown.
    final (:taken, :free) = book.places;

    // R19: "FULL", "N left" when 5 or fewer remain, nothing otherwise.
    final badge = book.isFull
        ? 'FULL'
        : free <= 5
        ? '$free left'
        : null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: genreColor.withValues(alpha: 0.16),
                      child: Icon(book.genre.icon, color: genreColor),
                    ),
                    if (badge != null)
                      Positioned(
                        bottom: -6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: book.isFull
                                ? scheme.error
                                : scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            child: Text(
                              badge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: book.isFull
                                    ? scheme.onError
                                    : scheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDate(book.meeting)} · $taken/${book.copies}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      book.online ? 'Online' : book.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: book.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                icon: Icon(
                  book.favourite ? Icons.favorite : Icons.favorite_border,
                  color: book.favourite ? scheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
