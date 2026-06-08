class MeasurementConverter {
  static String toImperial(String text) {
    return text.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?|\d+/\d+)\s*(g|kg|ml|l)\b', caseSensitive: false),
      (m) {
        final amount = _parse(m.group(1)!);
        if (amount == null) return m.group(0)!;
        return _convert(amount, m.group(2)!.toLowerCase());
      },
    );
  }

  static double? _parse(String s) {
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 2) {
        final n = double.tryParse(parts[0]);
        final d = double.tryParse(parts[1]);
        if (n != null && d != null && d != 0) return n / d;
      }
      return null;
    }
    return double.tryParse(s);
  }

  static String _convert(double amount, String unit) {
    switch (unit) {
      case 'g':
        if (amount >= 450) return '${_fmt(amount / 453.592)} lb';
        return '${_fmt(amount * 0.035274)} oz';
      case 'kg':
        return '${_fmt(amount * 2.20462)} lb';
      case 'ml':
        if (amount >= 60) return '${_fmtCups(amount / 240)} cups';
        return '${_fmt(amount * 0.033814)} fl oz';
      case 'l':
        if (amount >= 1) return '${_fmt(amount * 1.05669)} qt';
        return '${_fmtCups(amount * 4.22675)} cups';
      default:
        return '${_fmt(amount)} $unit';
    }
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  static String _fmtCups(double cups) {
    const thresholds = [0.25, 0.333, 0.5, 0.667, 0.75];
    const labels = ['¼', '⅓', '½', '⅔', '¾'];

    final whole = cups.truncate();
    final frac = cups - whole;

    if (frac < 0.1) return whole == 0 ? _fmt(cups) : '$whole';
    if (frac > 0.9) return '${whole + 1}';

    for (int i = 0; i < thresholds.length; i++) {
      if ((frac - thresholds[i]).abs() < 0.08) {
        return whole == 0 ? labels[i] : '$whole ${labels[i]}';
      }
    }
    return _fmt(cups);
  }
}
