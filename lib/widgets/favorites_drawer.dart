import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../screens/dish_detail_screen.dart';
import '../services/favorites_service.dart';
import '../theme/app_color_scheme.dart';

class FavoritesDrawer extends StatelessWidget {
  const FavoritesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded, color: scheme.primaryDark, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    'Saved Dishes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: scheme.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: scheme.textMedium),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.divider),
            Expanded(
              child: ListenableBuilder(
                listenable: FavoritesService.instance,
                builder: (context, _) {
                  final favorites = FavoritesService.instance.favorites;
                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 52, color: scheme.primaryDark),
                          const SizedBox(height: 14),
                          Text(
                            'No saved dishes yet.\nTap the heart on any dish to save it.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: scheme.textMedium,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: favorites.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, indent: 20, endIndent: 20, color: scheme.divider),
                    itemBuilder: (context, index) {
                      final dish = favorites[index];
                      return _FavoritesTile(dish: dish, scheme: scheme);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTile extends StatelessWidget {
  final Dish dish;
  final AppColorScheme scheme;
  const _FavoritesTile({required this.dish, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DishDetailScreen(dish: dish)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(Icons.restaurant_rounded, size: 36, color: scheme.primaryDark),
      title: Text(
        dish.name,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: scheme.textDark,
        ),
      ),
      subtitle: Text(
        dish.cuisine,
        style: TextStyle(fontSize: 13, color: scheme.primaryDark),
      ),
      trailing: IconButton(
        icon: Icon(Icons.favorite_rounded, color: scheme.primaryDark, size: 22),
        onPressed: () => FavoritesService.instance.toggle(dish),
      ),
    );
  }
}
