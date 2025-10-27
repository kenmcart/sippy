class MeasureUtils {
  // Converts an ingredient line based on unit system ('us' or 'metric'), with optional scaling.
  // Best-effort parse of measures inside parentheses. If parsing fails, returns original.
  static String convertLine(String line, String unitSystem, {double scale = 1.0}) {
    // Look for parenthetical measure e.g., "(2 oz)" or "(50ml)" or "1 oz"
    // We'll extract number + unit pairs.
    final regexParen = RegExp(r"\(([^\)]+)\)");
    final match = regexParen.firstMatch(line);
    String measure = '';
    if (match != null) {
      measure = match.group(1)!.trim();
    } else {
      // Try to find trailing measure like "Vodka 2 oz"
      final regexEnd = RegExp(r"(\d+[\d\/.]*\s*(oz|ml|tsp|tbsp))\b", caseSensitive: false);
      final match2 = regexEnd.firstMatch(line);
      if (match2 != null) measure = match2.group(0)!.trim();
    }

    if (measure.isEmpty) return line; // nothing to convert

  final converted = _convertMeasure(measure, unitSystem, scale: scale);
    if (converted == null) return line;

    if (match != null) {
      // Replace inside parentheses
      return line.replaceRange(match.start, match.end, '($converted)');
    } else {
      // Append converted in parentheses for clarity
      return '$line ($converted)';
    }
  }

  static String? _convertMeasure(String measure, String system, {double scale = 1.0}) {
    // Normalize
    String m = measure.toLowerCase().trim();
    m = m.replaceAll(' ', ' ');

    // Extract quantity (support fractions like 1/2, 1 1/2)
    final qtyMatch = RegExp(r"(?:(\d+\s+)?(\d+\/\d+)|\d+\.?\d*)").firstMatch(m);
    if (qtyMatch == null) return null;

  double qty = 0;
    final wholePart = qtyMatch.group(1);
    final fracPart = qtyMatch.group(2);
    if (fracPart != null) {
      // Has a fraction, possibly with whole part
      if (wholePart != null) qty += double.tryParse(wholePart.trim()) ?? 0;
      final parts = fracPart.split('/');
      final nume = double.tryParse(parts[0]) ?? 0;
      final deno = double.tryParse(parts[1]) ?? 1;
      qty += (deno == 0 ? 0 : nume / deno);
    } else {
      qty = double.tryParse(qtyMatch.group(0)!.trim()) ?? 0;
    }

    // Apply scaling factor (e.g., 2x, 4x)
    if (scale != 1.0) {
      qty *= scale;
    }

    final unitMatch = RegExp(r"(oz|ml|tsp|tbsp)").firstMatch(m);
    if (unitMatch == null) return null;
    final unit = unitMatch.group(1)!;

  if (system == 'metric') {
      // convert to ml
      double ml;
      switch (unit) {
        case 'ml':
          ml = qty;
          break;
        case 'oz':
          ml = qty * 29.5735;
          break;
        case 'tsp':
          ml = qty * 4.92892;
          break;
        case 'tbsp':
          ml = qty * 14.7868;
          break;
        default:
          return null;
      }
      return _formatNumber(ml) + ' ml';
    } else {
      // convert to US (oz)
      double oz;
      switch (unit) {
        case 'oz':
          oz = qty;
          break;
        case 'ml':
          oz = qty / 29.5735;
          break;
        case 'tsp':
          oz = qty * 0.166667; // 1 tsp = 1/6 fl oz
          break;
        case 'tbsp':
          oz = qty * 0.5; // 1 tbsp = 1/2 fl oz
          break;
        default:
          return null;
      }
      return _formatNumber(oz) + ' oz';
    }
  }

  static String _formatNumber(double n) {
    // Show at most 2 decimals, trim trailing zeros
    final s = n.toStringAsFixed(2);
    return s.replaceAll(RegExp(r"\.00$"), '').replaceAll(RegExp(r"0$"), '');
  }
}
