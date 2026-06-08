import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../services/api_service.dart';
import '../theme/app_color_scheme.dart';
import 'dish_detail_screen.dart';

class BrowseByNameScreen extends StatefulWidget {
  final bool autoFocusSearch;

  const BrowseByNameScreen({super.key, this.autoFocusSearch = false});

  @override
  State<BrowseByNameScreen> createState() => _BrowseByNameScreenState();
}

class _BrowseByNameScreenState extends State<BrowseByNameScreen> {
  List<Dish> _all = [];
  List<Dish> _filtered = [];
  bool _loading = true;
  bool _error = false;
  late final TextEditingController _search;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _focusNode = FocusNode();
    _search.addListener(_filter);
    _load();
  }

  Future<void> _load() async {
    try {
      final dishes = await ApiService.getAllDishes();
      if (!mounted) return;
      setState(() {
        _all = dishes;
        _filtered = dishes;
        _loading = false;
      });
      if (widget.autoFocusSearch) _focusNode.requestFocus();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _filter() {
    final q = _search.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
              .where((d) =>
                  d.name.toLowerCase().contains(q) ||
                  d.cuisine.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Builds a flat list of String (letter header) | Dish items for the A–Z view.
  List<dynamic> get _sectionedItems {
    final items = <dynamic>[];
    String? current;
    for (final dish in _all) {
      final letter = dish.name[0].toUpperCase();
      if (letter != current) {
        items.add(letter);
        current = letter;
      }
      items.add(dish);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    final isFiltering = _search.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Browse by Name'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: scheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Search dishes or cuisine...',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.white70),
                      suffixIcon: _search.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.white70),
                              onPressed: () => _search.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: scheme.primary))
                : _error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('😕',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'Could not reach the server.\nIs it running?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, color: scheme.textMedium),
                            ),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🔍',
                                    style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text(
                                  'No dishes matched "${_search.text}"',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: scheme.textMedium),
                                ),
                              ],
                            ),
                          )
                        : isFiltering
                            ? _buildFlatList(scheme)
                            : _buildSectionedList(scheme),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatList(AppColorScheme scheme) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filtered.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, indent: 72, color: scheme.divider),
      itemBuilder: (context, index) =>
          _DishTile(dish: _filtered[index], scheme: scheme),
    );
  }

  Widget _buildSectionedList(AppColorScheme scheme) {
    final items = _sectionedItems;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is String) {
          return _LetterHeader(letter: item, scheme: scheme);
        }
        final dish = item as Dish;
        // Show divider unless the next item is a header or end of list
        final nextIsHeader =
            index + 1 < items.length && items[index + 1] is String;
        return Column(
          children: [
            _DishTile(dish: dish, scheme: scheme),
            if (!nextIsHeader && index + 1 < items.length)
              Divider(height: 1, indent: 72, color: scheme.divider),
          ],
        );
      },
    );
  }
}

class _DishTile extends StatelessWidget {
  final Dish dish;
  final AppColorScheme scheme;

  const _DishTile({required this.dish, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DishDetailScreen(dish: dish)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Text(dish.emoji, style: const TextStyle(fontSize: 32)),
      title: Text(
        dish.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: scheme.textDark,
        ),
      ),
      subtitle: Text(
        dish.cuisine,
        style:
            TextStyle(fontSize: 12, color: scheme.primaryDark, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 13, color: scheme.textLight),
    );
  }
}

class _LetterHeader extends StatelessWidget {
  final String letter;
  final AppColorScheme scheme;

  const _LetterHeader({required this.letter, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      color: scheme.surface,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
