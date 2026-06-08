String formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(0).split('');
  final reversed = parts.reversed.toList();
  final result = <String>[];
  for (int i = 0; i < reversed.length; i++) {
    if (i > 0 && i % 3 == 0) result.add('.');
    result.add(reversed[i]);
  }
  return '${result.reversed.join()}₫';
}
