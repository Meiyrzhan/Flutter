import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';

/// Tab 2: the favourite books, same card as tab 1.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onToggleFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = books.where((book) => book.favourite).toList();
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse books',
        onAction: onBrowse,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: favourites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final book = favourites[index];
        return BookCard(
          book: book,
          onTap: () => onOpen(book),
          onToggleFavourite: () => onToggleFavourite(book),
        );
      },
    );
  }
}
