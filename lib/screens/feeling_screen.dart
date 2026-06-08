import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color_scheme.dart';
import 'results_screen.dart';

class _Option {
  final String emoji;
  final String label;
  final dynamic value;
  final Color color;

  const _Option({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _Question {
  final String emoji;
  final String text;
  final String key;
  final List<_Option> options;

  const _Question({
    required this.emoji,
    required this.text,
    required this.key,
    required this.options,
  });
}

const _questions = [
  _Question(
    emoji: '🌶️',
    text: 'How spicy do you want it?',
    key: 'spicy',
    options: [
      _Option(emoji: '😊', label: 'Mild', value: 'mild', color: Color(0xFF2E7D32)),
      _Option(emoji: '🌶️', label: 'Medium', value: 'medium', color: Color(0xFFFF6D00)),
      _Option(emoji: '🔥', label: 'Hot', value: 'hot', color: Color(0xFFBF360C)),
    ],
  ),
  _Question(
    emoji: '🍳',
    text: 'How complex a dish?',
    key: 'difficulty',
    options: [
      _Option(emoji: '😌', label: 'Easy', value: 'easy', color: Color(0xFF0277BD)),
      _Option(emoji: '🧑‍🍳', label: 'Medium', value: 'medium', color: Color(0xFFFF6D00)),
      _Option(emoji: '👨‍🎓', label: 'Hard', value: 'hard', color: Color(0xFF6A1B9A)),
    ],
  ),
];

class FeelingScreen extends StatefulWidget {
  const FeelingScreen({super.key});

  @override
  State<FeelingScreen> createState() => _FeelingScreenState();
}

class _FeelingScreenState extends State<FeelingScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  final Map<String, dynamic> _answers = {};
  bool _loading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _answer(dynamic value) async {
    final q = _questions[_step];
    _answers[q.key] = value;

    if (_step < _questions.length - 1) {
      await _animController.reverse();
      setState(() => _step++);
      _animController.forward();
      return;
    }

    setState(() => _loading = true);
    try {
      final dishes = await ApiService.searchByFeeling(_answers);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            dishes: dishes,
            title: '😋 Your Matches',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server. Is it running?')),
      );
      setState(() => _loading = false);
    }
  }

  Widget _buildOptions(List<_Option> options) {
    if (options.length == 2) {
      return Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: _OptionButton(option: options[i], onTap: () => _answer(options[i].value))),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _OptionButton(option: options[i], onTap: () => _answer(options[i].value), wide: true),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = AppTheme.of(context);
    final q = _questions[_step];

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primaryLight,
        foregroundColor: Colors.white,
        title: const Text('How are you feeling?'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _loading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: scheme.primaryLight),
                      const SizedBox(height: 16),
                      Text(
                        'Finding your perfect dish...',
                        style: TextStyle(fontSize: 16, color: scheme.textMedium),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(q.emoji, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 32),
                      Text(
                        q.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: scheme.textDark,
                          height: 1.25,
                        ),
                      ),
                      const Spacer(),
                      _buildOptions(q.options),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final _Option option;
  final VoidCallback onTap;
  final bool wide;

  const _OptionButton({
    required this.option,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: wide ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: wide ? 20 : 28,
          horizontal: wide ? 24 : 0,
        ),
        decoration: BoxDecoration(
          color: option.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: option.color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: wide
            ? Row(
                children: [
                  Text(option.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Text(option.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
