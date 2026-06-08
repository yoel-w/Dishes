import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_color_scheme.dart';
import 'dish_detail_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<Dish> dishes;
  final String title;
  final bool allowRespin;

  const ResultsScreen({
    super.key,
    required this.dishes,
    required this.title,
    this.allowRespin = false,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<Dish> _dishes;
  bool _respinLoading = false;

  @override
  void initState() {
    super.initState();
    _dishes = widget.dishes;
  }

  Future<void> _respin() async {
    setState(() => _respinLoading = true);
    try {
      final dish = await ApiService.getRandomDish();
      if (!mounted) return;
      setState(() => _dishes = [dish]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server. Is it running?')),
      );
    } finally {
      if (mounted) setState(() => _respinLoading = false);
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Breakfast':
        return const Color(0xFFF57C00);
      case 'Lunch/Dinner':
        return const Color(0xFF1565C0);
      case 'Snack':
        return const Color(0xFF2E7D32);
      case 'Dessert':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF546E7A);
    }
  }

  Color _spiceColor(String spice) {
    switch (spice) {
      case 'hot':
        return const Color(0xFFD32F2F);
      case 'medium':
        return const Color(0xFFFF6D00);
      default:
        return const Color(0xFF558B2F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _dishes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('😕', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No dishes found.\nTry different ingredients!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: scheme.textMedium),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dishes.length,
                    itemBuilder: (context, index) {
                      final dish = _dishes[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DishDetailScreen(dish: dish),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: scheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dish.emoji, style: const TextStyle(fontSize: 40)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dish.name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: scheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dish.cuisine,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: scheme.primaryDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        dish.description,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: scheme.textMedium,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          if (dish.category.isNotEmpty)
                                            _Chip(label: dish.category, color: _categoryColor(dish.category)),
                                          _Chip(label: dish.spice, color: _spiceColor(dish.spice)),
                                          _Chip(label: dish.difficulty, color: scheme.textMedium),
                                          _Chip(label: dish.prepTime, color: const Color(0xFF0277BD)),
                                          if (dish.matchCount != null)
                                            _Chip(
                                              label: '${dish.matchCount} matched',
                                              color: const Color(0xFF2E7D32),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ListenableBuilder(
                                  listenable: FavoritesService.instance,
                                  builder: (context, _) {
                                    final saved = FavoritesService.instance.isFavorite(dish.id);
                                    return IconButton(
                                      icon: Icon(
                                        saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: scheme.primaryDark,
                                      ),
                                      onPressed: () => FavoritesService.instance.toggle(dish),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (widget.allowRespin)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: GestureDetector(
                onTap: _respinLoading ? null : _respin,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: scheme.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _respinLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎲', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                'Respin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
