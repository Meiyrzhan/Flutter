import 'package:flutter/material.dart';

import '../models/game_category.dart';
import '../models/game_night.dart';
import '../utils/sorting.dart';
import '../widgets/empty_state.dart';
import '../widgets/night_list.dart';

/// Tab 1: search, category chips, past filter and the list itself.
class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.nights,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onCreate,
  });

  final List<GameNight> nights;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<String> onToggleFavourite;
  final VoidCallback onCreate;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  GameCategory? _category;
  bool _pastOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<GameNight> _visible() {
    final query = _query.trim().toLowerCase();
    final matches = widget.nights.where(
      (night) =>
          (query.isEmpty || night.title.toLowerCase().contains(query)) &&
          (_category == null || night.category == _category) &&
          (!_pastOnly || night.isPast),
    );
    return sortedByDate(matches);
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  Widget _body(List<GameNight> visible) {
    if (widget.nights.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy,
        message: 'No game nights yet',
        actionLabel: 'Create one',
        onAction: widget.onCreate,
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        message: 'No game nights match',
        actionLabel: _query.isEmpty ? null : 'Clear search',
        onAction: _query.isEmpty ? null : _clearSearch,
      );
    }
    return NightList(
      nights: visible,
      onOpen: widget.onOpen,
      onFavourite: widget.onToggleFavourite,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible();
    final freePlaces = visible.fold<int>(
      0,
      (sum, night) => sum + night.freeSeats,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onCreate,
        tooltip: 'New game night',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: 'Search by title',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Past'),
                  selected: _pastOnly,
                  onSelected: (value) => setState(() => _pastOnly = value),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final category in GameCategory.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(category.icon, size: 18),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${visible.length} nights · $freePlaces free places',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          Expanded(child: _body(visible)),
        ],
      ),
    );
  }
}
