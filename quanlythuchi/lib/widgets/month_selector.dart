import 'package:flutter/material.dart';
import 'package:quanlythuchi/utils/theme.dart';

class MonthSelector extends StatelessWidget {
  final int month;
  final int year;
  final ValueChanged<int> onMonthChange;
  final Color? backgroundColor;

  const MonthSelector({super.key, required this.month, required this.year, required this.onMonthChange, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: backgroundColor ?? AppTheme.primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => onMonthChange(-1)),
          Text('Tháng $month năm $year', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => onMonthChange(1)),
        ],
      ),
    );
  }
}