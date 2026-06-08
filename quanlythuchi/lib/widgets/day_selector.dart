import 'package:flutter/material.dart';
import 'package:quanlythuchi/utils/theme.dart';

class DaySelector extends StatelessWidget {
  final int day;
  final int month;
  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Color? backgroundColor;

  const DaySelector({super.key, required this.day, required this.month, required this.year, required this.onPrevious, required this.onNext, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = day == now.day && month == now.month && year == now.year;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: backgroundColor ?? AppTheme.primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: onPrevious),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${day.toString().padLeft(2, "0")}/${month.toString().padLeft(2, "0")}/$year',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            if (isToday) const Text('Hôm nay', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ]),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: onNext),
        ],
      ),
    );
  }
}