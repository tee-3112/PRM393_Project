import 'package:flutter/material.dart';
import 'package:quanlythuchi/utils/currency_formatter.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final int count;
  final Color color;
  final Color darkColor;

  const SummaryCard({super.key, required this.title, required this.amount, required this.count, required this.color, required this.darkColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [darkColor, color]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(formatCurrency(amount), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$count giao dịch', style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }
}