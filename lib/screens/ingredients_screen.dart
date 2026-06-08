import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color_scheme.dart';
import 'results_screen.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _ingredients = [];
  bool _loading = false;

  void _addIngredient() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_ingredients.contains(text.toLowerCase())) {
      _controller.clear();
      return;
    }
    setState(() {
      _ingredients.add(text.toLowerCase());
      _controller.clear();
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() => _ingredients.remove(ingredient));
  }

  Future<void> _search() async {
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient first')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final results = await ApiService.searchByIngredients(_ingredients);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            dishes: results,
            title: 'Matching Dishes',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server. Is it running?')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: const Text('What do you have?'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your ingredients',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: scheme.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add one at a time and we\'ll find dishes that match.',
              style: TextStyle(fontSize: 14, color: scheme.textMedium),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addIngredient(),
                    style: TextStyle(color: scheme.textDark),
                    decoration: InputDecoration(
                      hintText: 'e.g. chicken, garlic, rice...',
                      hintStyle: TextStyle(color: scheme.textLight),
                      filled: true,
                      fillColor: scheme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addIngredient,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_ingredients.isNotEmpty) ...[
              Text(
                'Your ingredients:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.textMedium,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ingredients.map((ingredient) {
                  return Chip(
                    label: Text(
                      ingredient,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: scheme.primaryLight,
                    deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                    onDeleted: () => _removeIngredient(ingredient),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _loading ? null : _search,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: _ingredients.isEmpty
                        ? scheme.textLight
                        : scheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _ingredients.isEmpty
                        ? []
                        : [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Find Dishes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
