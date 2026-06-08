import 'package:flutter/material.dart';

class AppColorScheme {
  final String id;
  final String name;
  final Color background;
  final Color surface;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final Color cardColor;
  final Color textDark;
  final Color textMedium;
  final Color textLight;
  final Color divider;

  const AppColorScheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.cardColor,
    required this.textDark,
    required this.textMedium,
    required this.textLight,
    required this.divider,
  });

  static const orange = AppColorScheme(
    id: 'orange',
    name: 'Orange',
    background: Color(0xFFFFF8F0),
    surface: Color(0xFFFFF3E0),
    primary: Color(0xFFE65100),
    primaryDark: Color(0xFFBF360C),
    primaryLight: Color(0xFFFF6D00),
    accent: Color(0xFFFF8F00),
    cardColor: Colors.white,
    textDark: Color(0xFF3E2723),
    textMedium: Color(0xFF8D6E63),
    textLight: Color(0xFFBCAAA4),
    divider: Color(0xFFD7CCC8),
  );

  static const lavender = AppColorScheme(
    id: 'lavender',
    name: 'Lavender',
    background: Color(0xFFE6E6FA),  // Lavender web
    surface: Color(0xFFEED3E6),     // Mimi Pink
    primary: Color(0xFF8B5B9A),     // dark purple  → Ingredients button
    primaryDark: Color(0xFF5E3570),
    primaryLight: Color(0xFFB080C0), // medium purple → Mood button
    accent: Color(0xFFD9B5DD),      // Pink lavender → Surprise Me button
    cardColor: Colors.white,
    textDark: Color(0xFF2D1A3D),
    textMedium: Color(0xFF8B6898),
    textLight: Color(0xFFC29DC2),   // Lilac
    divider: Color(0xFFE4C4E2),     // Thistle
  );

  static const coral = AppColorScheme(
    id: 'coral',
    name: 'Coral',
    background: Color(0xFFFFE5D9),  // Champagne pink
    surface: Color(0xFFFFD8CA),     // Pale Dogwood
    primary: Color(0xFFCF5A48),     // dark coral    → Ingredients button
    primaryDark: Color(0xFFA03528),
    primaryLight: Color(0xFFE08070), // medium coral  → Mood button
    accent: Color(0xFFF2ACB6),      // Cherry blossom → Surprise Me button
    cardColor: Colors.white,
    textDark: Color(0xFF2D1010),
    textMedium: Color(0xFF937A7A),  // Cinereous
    textLight: Color(0xFFC4A098),
    divider: Color(0xFFD8E2DC),     // Platinum
  );

  static const beige = AppColorScheme(
    id: 'beige',
    name: 'Beige',
    background: Color(0xFFF5F5DC),  // Beige
    surface: Color(0xFFE6E0D4),     // Bone
    primary: Color(0xFF5A6878),     // dark blue-gray  → Ingredients button
    primaryDark: Color(0xFF3A4858), // deep blue-gray
    primaryLight: Color(0xFF8A9DB8), // medium blue-gray → Mood button
    accent: Color(0xFFC2CFDF),      // Columbia blue   → Surprise Me button
    cardColor: Colors.white,
    textDark: Color(0xFF1A2030),
    textMedium: Color(0xFF607080),
    textLight: Color(0xFFB0BBCC),
    divider: Color(0xFFDCE2DE),     // Platinum
  );

  static const green = AppColorScheme(
    id: 'green',
    name: 'Green',
    background: Color(0xFFF2FAE9),   // Honeydew
    surface: Color(0xFFE7FFCE),      // Nyanza
    primary: Color(0xFF4A7A5A),      // dark sage      → Ingredients button
    primaryDark: Color(0xFF2D5C40),  // deep forest
    primaryLight: Color(0xFF78A878), // medium sage    → Mood button
    accent: Color(0xFFB6DA9F),       // Celadon        → Surprise Me button
    cardColor: Colors.white,
    textDark: Color(0xFF1A3020),
    textMedium: Color(0xFF5A7A60),
    textLight: Color(0xFFA8C8A8),
    divider: Color(0xFFD8FFB1),      // Tea green
  );

  static const cream = AppColorScheme(
    id: 'cream',
    name: 'Cream',
    background: Color(0xFFFFFFFB),   // Baby powder
    surface: Color(0xFFFFFCEE),      // Ivory
    primary: Color(0xFF7A6030),      // dark warm gold  → Ingredients button
    primaryDark: Color(0xFF5A4020),  // deep amber
    primaryLight: Color(0xFFA8843C), // medium gold     → Mood button
    accent: Color(0xFFD4B870),       // light gold      → Surprise Me button
    cardColor: Colors.white,
    textDark: Color(0xFF2A1E08),
    textMedium: Color(0xFF8A7040),
    textLight: Color(0xFFC8A868),
    divider: Color(0xFFFEF5D3),      // Cornsilk
  );

  static const all = [orange, lavender, coral, beige, green, cream];
}

class AppTheme extends InheritedWidget {
  final AppColorScheme scheme;

  const AppTheme({super.key, required this.scheme, required super.child});

  static AppColorScheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppTheme>()!.scheme;

  @override
  bool updateShouldNotify(AppTheme old) => scheme.id != old.scheme.id;
}
