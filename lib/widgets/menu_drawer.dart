import 'package:flutter/material.dart';
import '../screens/country_list_screen.dart';
import '../screens/results_screen.dart';
import '../screens/settings_screen.dart';
import '../services/api_service.dart';
import '../theme/app_color_scheme.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

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
                  const Text('🍽️', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Text(
                    'Menu',
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
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  _MenuItem(
                    emoji: '⚙️',
                    label: 'Settings',
                    subtitle: 'Preferences and options',
                    scheme: scheme,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 24, color: scheme.divider),
                  ),
                  _RegionsExpansion(scheme: scheme),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 24, color: scheme.divider),
                  ),
                  _MenuItem(
                    emoji: 'ℹ️',
                    label: 'About',
                    subtitle: 'Dish Discovery v1.0',
                    scheme: scheme,
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: 'Dish Discovery',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Text('🍽️',
                            style: TextStyle(fontSize: 36)),
                        children: const [
                          Text(
                            'Explore dishes from around the world — by ingredients, mood, or pure chance.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'World cuisines at your fingertips',
                style: TextStyle(fontSize: 12, color: scheme.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionsExpansion extends StatelessWidget {
  static const _regions = [
    ('🇺🇸', 'North America', 'northamerica'),
    ('🌎', 'South America', 'southamerica'),
    ('🏝️', 'Caribbean', 'caribbean'),
    ('🇪🇺', 'Europe', 'europe'),
    ('🌍', 'Africa', 'africa'),
    ('🕌', 'Middle East', 'middleeast'),
    ('🌏', 'Asia', 'asia'),
    ('🦘', 'Oceania', 'oceania'),
  ];

  final AppColorScheme scheme;
  const _RegionsExpansion({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: const Text('🌐', style: TextStyle(fontSize: 28)),
        title: Text(
          'Browse by Region',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: scheme.textDark,
          ),
        ),
        subtitle: Text(
          'Explore world cuisines',
          style: TextStyle(fontSize: 12, color: scheme.textMedium),
        ),
        trailing: Icon(Icons.expand_more_rounded, color: scheme.textLight),
        children: _regions
            .map((r) => _RegionTile(emoji: r.$1, label: r.$2, region: r.$3, scheme: scheme))
            .toList(),
      ),
    );
  }
}

class _RegionTile extends StatefulWidget {
  final String emoji;
  final String label;
  final String region;
  final AppColorScheme scheme;

  const _RegionTile({
    required this.emoji,
    required this.label,
    required this.region,
    required this.scheme,
  });

  @override
  State<_RegionTile> createState() => _RegionTileState();
}

class _RegionTileState extends State<_RegionTile> {
  bool _loading = false;

  Future<void> _browse() async {
    setState(() => _loading = true);
    try {
      final dishes = await ApiService.searchByRegion(widget.region);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            dishes: dishes,
            title: '${widget.emoji} ${widget.label}',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not reach the server. Is it running?')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
        leading: Text(widget.emoji, style: const TextStyle(fontSize: 22)),
        title: Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: scheme.textMedium,
          ),
        ),
        trailing: Icon(Icons.expand_more_rounded, size: 16, color: scheme.textLight),
        children: [
          ListTile(
            onTap: _loading ? null : _browse,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 52, vertical: 0),
            leading: _loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  )
                : Icon(Icons.restaurant_menu_rounded,
                    size: 18, color: scheme.textMedium),
            title: Text(
              'All Dishes',
              style: TextStyle(fontSize: 13, color: scheme.textMedium),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: scheme.textLight),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CountryListScreen(
                    emoji: widget.emoji,
                    label: widget.label,
                    region: widget.region,
                  ),
                ),
              );
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 52, vertical: 0),
            leading: Icon(Icons.flag_rounded, size: 18, color: scheme.textMedium),
            title: Text(
              'Country List',
              style: TextStyle(fontSize: 13, color: scheme.textMedium),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: scheme.textLight),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final AppColorScheme scheme;

  const _MenuItem({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Text(emoji, style: const TextStyle(fontSize: 28)),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: scheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: scheme.textMedium),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: scheme.textLight),
    );
  }
}
