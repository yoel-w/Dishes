import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../services/favorites_service.dart';
import '../services/measurement_service.dart';
import '../theme/app_color_scheme.dart';
import '../theme/theme_service.dart';

class DishDetailScreen extends StatelessWidget {
  final Dish dish;

  const DishDetailScreen({super.key, required this.dish});

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
      backgroundColor: scheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: scheme.primary,
            foregroundColor: Colors.white,
            actions: [
              ListenableBuilder(
                listenable: FavoritesService.instance,
                builder: (context, _) {
                  final saved = FavoritesService.instance.isFavorite(dish.id);
                  return IconButton(
                    icon: Icon(
                      saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => FavoritesService.instance.toggle(dish),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [scheme.primaryDark, scheme.primary],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(dish.emoji, style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 8),
                    Text(
                      dish.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country + meta row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(dish.flag, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dish.country,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.textDark,
                                  ),
                                ),
                                Text(
                                  dish.cuisine,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: scheme.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (dish.category.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _categoryColor(dish.category).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: _categoryColor(dish.category).withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      dish.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _categoryColor(dish.category),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(height: 1, color: scheme.divider),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MetaStat(icon: Icons.people_outline_rounded, label: dish.servings, scheme: scheme),
                            _MetaStat(icon: Icons.timer_outlined, label: dish.prepTime, scheme: scheme),
                            _MetaStat(
                              icon: Icons.local_fire_department_outlined,
                              label: dish.spice,
                              color: _spiceColor(dish.spice),
                              scheme: scheme,
                            ),
                            _MetaStat(icon: Icons.bar_chart_rounded, label: dish.difficulty, scheme: scheme),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    dish.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: scheme.textMedium,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ingredients
                  _SectionHeader(title: 'Ingredients', icon: Icons.kitchen_rounded, scheme: scheme),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListenableBuilder(
                      listenable: ThemeService.instance,
                      builder: (context, _) {
                        final useImperial = ThemeService.instance.useImperial;
                        return Column(
                          children: dish.ingredientsFull.asMap().entries.map((entry) {
                            final isLast = entry.key == dish.ingredientsFull.length - 1;
                            final text = useImperial
                                ? MeasurementConverter.toImperial(entry.value)
                                : entry.value;
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: scheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: scheme.textDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Divider(height: 1, indent: 36, color: scheme.divider),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  _SectionHeader(title: 'How to Make It', icon: Icons.menu_book_rounded, scheme: scheme),
                  const SizedBox(height: 12),
                  ...dish.instructions.asMap().entries.map((entry) {
                    final step = entry.key + 1;
                    return ListenableBuilder(
                      listenable: ThemeService.instance,
                      builder: (context, _) {
                        final text = ThemeService.instance.useImperial
                            ? MeasurementConverter.toImperial(entry.value)
                            : entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$step',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: scheme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: scheme.textDark,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 24),

                  // Nutrition Facts
                  if (dish.nutrition != null) ...[
                    _SectionHeader(title: 'Nutrition Facts', icon: Icons.monitor_heart_outlined, scheme: scheme),
                    const SizedBox(height: 4),
                    Text(
                      'Per serving (${dish.servings})',
                      style: TextStyle(fontSize: 12, color: scheme.textLight),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _NutritionRow(
                            label: 'Calories',
                            value: '${dish.nutrition!.calories} kcal',
                            highlight: true,
                            scheme: scheme,
                          ),
                          Divider(height: 20, color: scheme.divider),
                          Row(
                            children: [
                              Expanded(
                                child: _NutritionBar(
                                  label: 'Protein',
                                  value: dish.nutrition!.protein,
                                  unit: 'g',
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NutritionBar(
                                  label: 'Carbs',
                                  value: dish.nutrition!.carbs,
                                  unit: 'g',
                                  color: const Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _NutritionBar(
                                  label: 'Fat',
                                  value: dish.nutrition!.fat,
                                  unit: 'g',
                                  color: const Color(0xFFFF8F00),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NutritionBar(
                                  label: 'Fiber',
                                  value: dish.nutrition!.fiber,
                                  unit: 'g',
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppColorScheme scheme;

  const _SectionHeader({required this.title, required this.icon, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: scheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _MetaStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final AppColorScheme scheme;

  const _MetaStat({required this.icon, required this.label, required this.scheme, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? scheme.textMedium;
    return Column(
      children: [
        Icon(icon, color: c, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: c,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final AppColorScheme scheme;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.scheme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
            color: scheme.textDark,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: highlight ? scheme.primary : scheme.textMedium,
          ),
        ),
      ],
    );
  }
}

class _NutritionBar extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;

  const _NutritionBar({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63)),
            ),
            Text(
              '$value$unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
