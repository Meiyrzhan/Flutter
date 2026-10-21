import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/genre.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';

/// Tab 1: search, genre chips, past filter and the list or grid.
class LibraryTab extends StatefulWidget {
  const LibraryTab({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onAdd,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onToggleFavourite;
  final VoidCallback onAdd;

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final _search = TextEditingController();
  String _query = '';
  Genre? _genre;
  bool _showPast = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// R7: filter with a collection for/if, then sort a copy (upcoming first,
  /// past last) - the state list is never sorted in place.
  List<Book> _visible() {
    final query = _query.trim().toLowerCase();
    final filtered = [
      for (final book in widget.books)
        if ((_genre == null || book.genre == _genre) &&
            (_showPast || !book.isPast) &&
            (query.isEmpty || book.title.toLowerCase().contains(query)))
          book,
    ];
    final sorted = [...filtered]
      ..sort((a, b) {
        if (a.isPast != b.isPast) {
          return a.isPast ? 1 : -1;
        }
        return a.meeting.compareTo(b.meeting);
      });
    return sorted;
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final books = _visible();

    // R21: one Column, the list in Expanded, no shrinkWrap, no fixed heights.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _genre == null,
                onSelected: (_) => setState(() => _genre = null),
              ),
              for (final genre in Genre.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(genre.icon, size: 18),
                  label: Text(genre.label),
                  selected: _genre == genre,
                  onSelected: (_) => setState(() => _genre = genre),
                ),
              ],
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: books.isEmpty ? _empty() : _list(books),
        ),
      ],
    );
  }

  Widget _empty() {
    if (widget.books.isEmpty) {
      return EmptyState(
        icon: Icons.menu_book,
        message: 'No books yet',
        actionLabel: 'Add a book',
        onAction: widget.onAdd,
      );
    }
    return EmptyState(
      icon: Icons.search_off,
      message: 'No books match',
      actionLabel: _query.isEmpty ? null : 'Clear search',
      onAction: _clearSearch,
    );
  }

  Widget _card(Book book) {
    return BookCard(
      book: book,
      onTap: () => widget.onOpen(book),
      onToggleFavourite: () => widget.onToggleFavourite(book),
    );
  }

  /// R20: phones get a list, 600 px and wider a grid with cells of at most
  /// 360 px. The decision is the width this tab is given (LayoutBuilder),
  /// not the screen size (MediaQuery).
  Widget _list(List<Book> books) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 128,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) => _card(books[index]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
          itemCount: books.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _card(books[index]),
        );
      },
    );
  }
}
