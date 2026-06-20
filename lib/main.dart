import 'package:flutter/material.dart';
import 'screens/feeling_screen.dart';
import 'screens/ingredients_screen.dart';
import 'screens/results_screen.dart';
import 'services/api_service.dart';
import 'services/favorites_service.dart';
import 'theme/app_color_scheme.dart';
import 'theme/theme_service.dart';
import 'widgets/favorites_drawer.dart';
import 'widgets/menu_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.load();
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final scheme = ThemeService.instance.scheme;
        return AppTheme(
          scheme: scheme,
          child: MaterialApp(
            title: 'Dish Discovery',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: scheme.primary),
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: scheme.background,
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                    ThemeService.instance.textScale),
              ),
              child: child!,
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _surpriseLoading = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.load();
  }

  Future<void> _onSurpriseMe() async {
    setState(() => _surpriseLoading = true);
    try {
      final dish = await ApiService.getRandomDish();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            dishes: [dish],
            title: 'Surprise!',
            allowRespin: true,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server. Is it running?')),
      );
    } finally {
      if (mounted) setState(() => _surpriseLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: scheme.surface,
      drawer: const FavoritesDrawer(),
      endDrawer: const MenuDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  ListenableBuilder(
                    listenable: FavoritesService.instance,
                    builder: (context, _) {
                      final count = FavoritesService.instance.favorites.length;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite_rounded,
                              color: scheme.primaryDark,
                              size: 30,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                          if (count > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        color: scheme.textMedium,
                        size: 30,
                      ),
                      onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.restaurant_menu_rounded,
                size: 64,
                color: scheme.primaryDark,
              ),
              const SizedBox(height: 16),
              Text(
                'Discover New Dishes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scheme.primaryDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore dishes from around the world',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.textMedium,
                ),
              ),
              const SizedBox(height: 60),
              _HomeButton(
                label: 'Ingredients',
                subtitle: 'Tell us what you have',
                icon: Icons.kitchen_rounded,
                color: scheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IngredientsScreen()),
                ),
              ),
              const SizedBox(height: 18),
              _HomeButton(
                label: 'Mood',
                subtitle: 'Answer a few questions',
                icon: Icons.mood_rounded,
                color: scheme.primaryLight,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeelingScreen()),
                ),
              ),
              const SizedBox(height: 18),
              _HomeButton(
                label: _surpriseLoading ? 'Finding...' : 'Surprise Me!',
                subtitle: 'Random dish from anywhere',
                icon: Icons.casino_rounded,
                color: scheme.accent,
                onTap: _surpriseLoading ? () {} : _onSurpriseMe,
              ),
              const Spacer(),
              Text(
                'World cuisines at your fingertips',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.textLight,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: Colors.white, size: 28),
            if (icon != null) const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}
