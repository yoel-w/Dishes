import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../theme/theme_service.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _previewScale;

  @override
  void initState() {
    super.initState();
    _previewScale = ThemeService.instance.textScale;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: scheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: scheme.textDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 4),
          _AppearanceCard(
            scheme: scheme,
            previewScale: _previewScale,
            onScaleChanged: (v) => setState(() => _previewScale = v),
            onScaleEnd: (v) => ThemeService.instance.setTextScale(v),
          ),
        ],
      ),
    );
  }
}

// ── Appearance card with two expansion tiles ──────────────────────────────────

class _AppearanceCard extends StatelessWidget {
  final AppColorScheme scheme;
  final double previewScale;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onScaleEnd;

  const _AppearanceCard({
    required this.scheme,
    required this.previewScale,
    required this.onScaleChanged,
    required this.onScaleEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Column(
            children: [
              // ── Theme Color ──
              ExpansionTile(
                initiallyExpanded: false,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Icon(Icons.palette_rounded, color: scheme.primary),
                title: Text(
                  'Theme Color',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.textDark),
                ),
                subtitle: Text(
                  'Customize the app color',
                  style: TextStyle(fontSize: 12, color: scheme.textMedium),
                ),
                trailing:
                    Icon(Icons.expand_more_rounded, color: scheme.textLight),
                children: [
                  Divider(height: 1, color: scheme.divider),
                  const SizedBox(height: 24),
                  _HomePreview(),
                  const SizedBox(height: 24),
                  _SwatchRow(parentScheme: scheme),
                  const SizedBox(height: 20),
                ],
              ),

              Divider(height: 1, color: scheme.divider),

              // ── Text Size ──
              ExpansionTile(
                initiallyExpanded: false,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading:
                    Icon(Icons.text_fields_rounded, color: scheme.primary),
                title: Text(
                  'Text Size',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.textDark),
                ),
                subtitle: Text(
                  'Adjust the size of text throughout the app',
                  style: TextStyle(fontSize: 12, color: scheme.textMedium),
                ),
                trailing:
                    Icon(Icons.expand_more_rounded, color: scheme.textLight),
                children: [
                  Divider(height: 1, color: scheme.divider),
                  const SizedBox(height: 24),
                  _DishPreview(scheme: scheme, textScale: previewScale),
                  const SizedBox(height: 24),
                  _TextSizeSlider(
                    scheme: scheme,
                    value: previewScale,
                    onChanged: onScaleChanged,
                    onChangeEnd: onScaleEnd,
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              Divider(height: 1, color: scheme.divider),

              // ── Units ──
              ListenableBuilder(
                listenable: ThemeService.instance,
                builder: (context, _) {
                  final imperial = ThemeService.instance.useImperial;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.straighten_rounded, color: scheme.primary, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Units',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.textDark,
                                ),
                              ),
                              Text(
                                imperial ? 'oz, lb, fl oz, cups' : 'g, kg, ml, L',
                                style: TextStyle(fontSize: 12, color: scheme.textMedium),
                              ),
                            ],
                          ),
                        ),
                        _UnitToggle(imperial: imperial, scheme: scheme),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared phone frame shell ──────────────────────────────────────────────────

class _PhoneFrame extends StatelessWidget {
  final AppColorScheme scheme;
  final Widget child;

  const _PhoneFrame({required this.scheme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 190,
        height: 370,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: scheme.divider, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            children: [
              // Notch bar
              Container(
                height: 26,
                color: scheme.surface,
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: scheme.textLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Expanded(child: child),
              // Home indicator
              Container(
                height: 18,
                color: scheme.surface,
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.textLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Home screen preview (for Theme Color) ─────────────────────────────────────

class _HomePreview extends StatelessWidget {
  const _HomePreview();

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    return _PhoneFrame(
      scheme: scheme,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.favorite_rounded,
                    color: scheme.primaryDark, size: 14),
                Icon(Icons.menu_rounded, color: scheme.textMedium, size: 14),
              ],
            ),
            const SizedBox(height: 10),
            Icon(Icons.restaurant_menu_rounded, size: 26, color: scheme.primaryDark),
            const SizedBox(height: 6),
            Text(
              'Discover New Dishes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: scheme.primaryDark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Explore dishes from around the world',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 6.5, color: scheme.textMedium),
            ),
            const SizedBox(height: 14),
            _MiniButton(label: 'Ingredients', icon: Icons.kitchen_rounded, color: scheme.primary),
            const SizedBox(height: 5),
            _MiniButton(label: 'Mood', icon: Icons.mood_rounded, color: scheme.primaryLight),
            const SizedBox(height: 5),
            _MiniButton(label: 'Surprise Me!', icon: Icons.casino_rounded, color: scheme.accent),
            const Spacer(),
            Text(
              'World cuisines at your fingertips',
              style: TextStyle(fontSize: 5.5, color: scheme.textLight),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _MiniButton({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 9),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dish detail preview (for Text Size) ──────────────────────────────────────

class _DishPreview extends StatelessWidget {
  final AppColorScheme scheme;
  final double textScale;

  const _DishPreview({required this.scheme, required this.textScale});

  @override
  Widget build(BuildContext context) {
    return _PhoneFrame(
      scheme: scheme,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: Column(
          children: [
            // Pinned mini app bar
            Container(
              height: 28,
              color: scheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 13),
                  Icon(Icons.favorite_border_rounded,
                      color: Colors.white, size: 13),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ingredients header
                    _PreviewSectionHeader(
                      icon: Icons.kitchen_rounded,
                      label: 'Ingredients',
                      scheme: scheme,
                    ),
                    const SizedBox(height: 6),
                    _PreviewIngredient('200g glutinous rice', scheme),
                    _PreviewIngredient('400ml coconut milk', scheme),
                    _PreviewIngredient('3 tbsp sugar', scheme),
                    _PreviewIngredient('1/2 tsp salt', scheme),
                    _PreviewIngredient('2 ripe mangoes, sliced', scheme),
                    const SizedBox(height: 10),
                    // How to make it header
                    _PreviewSectionHeader(
                      icon: Icons.menu_book_rounded,
                      label: 'How to Make It',
                      scheme: scheme,
                    ),
                    const SizedBox(height: 6),
                    _PreviewStep(
                      number: 1,
                      text:
                          'Soak glutinous rice in cold water for at least 4 hours, or overnight. Drain thoroughly.',
                      scheme: scheme,
                    ),
                    const SizedBox(height: 5),
                    _PreviewStep(
                      number: 2,
                      text:
                          'Set up a bamboo steamer. Steam rice for 20–25 minutes until translucent and tender.',
                      scheme: scheme,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColorScheme scheme;

  const _PreviewSectionHeader(
      {required this.icon, required this.label, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 11),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _PreviewIngredient extends StatelessWidget {
  final String text;
  final AppColorScheme scheme;

  const _PreviewIngredient(this.text, this.scheme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(right: 6, left: 2),
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 7.5, color: scheme.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewStep extends StatelessWidget {
  final int number;
  final String text;
  final AppColorScheme scheme;

  const _PreviewStep(
      {required this.number, required this.text, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 7.5, color: scheme.textDark, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Text size slider ──────────────────────────────────────────────────────────

class _TextSizeSlider extends StatelessWidget {
  final AppColorScheme scheme;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _TextSizeSlider({
    required this.scheme,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  static const _steps = [0.9, 1.0, 1.1];
  static const _labels = ['Small', 'Default', 'Large'];

  String get _currentLabel {
    final idx = _steps.indexOf(value);
    return idx >= 0 ? _labels[idx] : 'Default';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Current size label
          Text(
            _currentLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: scheme.primary,
              inactiveTrackColor: scheme.divider,
              thumbColor: scheme.primary,
              overlayColor: scheme.primary.withValues(alpha: 0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: 0.9,
              max: 1.1,
              divisions: 2,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          // Step labels row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _labels
                  .asMap()
                  .entries
                  .map((e) => Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: value == _steps[e.key]
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: value == _steps[e.key]
                              ? scheme.primary
                              : scheme.textLight,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Horizontal swatch row (Theme Color) ───────────────────────────────────────

class _SwatchRow extends StatelessWidget {
  final AppColorScheme parentScheme;
  const _SwatchRow({required this.parentScheme});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final current = ThemeService.instance.scheme;
        return SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: AppColorScheme.all.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final s = AppColorScheme.all[i];
              final selected = s.id == current.id;
              return GestureDetector(
                onTap: () => ThemeService.instance.setScheme(s),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: s.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? s.primary : s.divider,
                              width: selected ? 3 : 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: s.primary,
                            shape: BoxShape.circle,
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Unit toggle (Imperial / Metric) ──────────────────────────────────────────

class _UnitToggle extends StatelessWidget {
  final bool imperial;
  final AppColorScheme scheme;

  const _UnitToggle({required this.imperial, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Imperial',
            selected: imperial,
            scheme: scheme,
            onTap: () => ThemeService.instance.setUseImperial(true),
          ),
          _Segment(
            label: 'Metric',
            selected: !imperial,
            scheme: scheme,
            onTap: () => ThemeService.instance.setUseImperial(false),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final AppColorScheme scheme;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : scheme.textMedium,
          ),
        ),
      ),
    );
  }
}
