import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../services/api_service.dart';
import '../theme/app_color_scheme.dart';
import 'results_screen.dart';

class CountryListScreen extends StatefulWidget {
  final String? flag;
  final String label;
  final String region;

  const CountryListScreen({
    super.key,
    this.flag,
    required this.label,
    required this.region,
  });

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  List<_CountryEntry>? _countries;
  Map<String, List<Dish>>? _dishesByCountry;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dishes = await ApiService.searchByRegion(widget.region);
      final map = <String, List<Dish>>{};
      for (final dish in dishes) {
        map.putIfAbsent(dish.country, () => []).add(dish);
      }
      final countries = map.entries
          .map((e) => _CountryEntry(
                country: e.key,
                flag: e.value.first.flag,
                count: e.value.length,
              ))
          .toList()
        ..sort((a, b) => a.country.compareTo(b.country));
      if (mounted) {
        setState(() {
          _countries = countries;
          _dishesByCountry = map;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load countries.');
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.flag != null ? '${widget.flag} ${widget.label}' : widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: scheme.textDark,
              ),
            ),
            Text(
              'Select a country',
              style: TextStyle(fontSize: 12, color: scheme.textMedium),
            ),
          ],
        ),
      ),
      body: _buildBody(scheme),
    );
  }

  Widget _buildBody(AppColorScheme scheme) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 48, color: scheme.textMedium),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: scheme.textMedium)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _error = null);
                _load();
              },
              child: Text('Retry', style: TextStyle(color: scheme.primary)),
            ),
          ],
        ),
      );
    }

    if (_countries == null) {
      return Center(
        child: CircularProgressIndicator(color: scheme.primary),
      );
    }

    if (_countries!.isEmpty) {
      return Center(
        child: Text('No countries found.',
            style: TextStyle(color: scheme.textMedium)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _countries!.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: scheme.divider,
      ),
      itemBuilder: (context, i) {
        final entry = _countries![i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: Text(entry.flag, style: const TextStyle(fontSize: 30)),
          title: Text(
            entry.country,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: scheme.textDark,
            ),
          ),
          subtitle: Text(
            '${entry.count} dish${entry.count == 1 ? '' : 'es'}',
            style: TextStyle(fontSize: 12, color: scheme.textMedium),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: scheme.textLight),
          onTap: () {
            final dishes = _dishesByCountry![entry.country]!;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultsScreen(
                  dishes: dishes,
                  title: '${entry.flag} ${entry.country}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CountryEntry {
  final String country;
  final String flag;
  final int count;
  const _CountryEntry(
      {required this.country, required this.flag, required this.count});
}
