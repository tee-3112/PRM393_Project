import 'package:flutter/material.dart';
import 'package:quanlythuchi/models/budget.dart';
import 'package:quanlythuchi/utils/theme.dart';
import 'package:quanlythuchi/utils/currency_formatter.dart';
import 'package:quanlythuchi/data/categories.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCard({super.key, required this.budget, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final usagePercent = budget.usagePercent.clamp(0, 100);
    final barColor = usagePercent >= 90 ? AppTheme.warningColor : (usagePercent >= 70 ? Colors.orange : AppTheme.primaryGreen);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(CategoryInfo.emoji(budget.categoryId), style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(budget.categoryName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 2),
              Row(children: [
                Text(formatCurrency(budget.spentAmount), style: TextStyle(fontSize: 13, color: barColor, fontWeight: FontWeight.w600)),
                Text(' / ${formatCurrency(budget.amount)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ]),
            ])),
            if (budget.isWarning)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.warningColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('Sắp hết', style: TextStyle(color: AppTheme.warningColor, fontSize: 11, fontWeight: FontWeight.bold)))
            else
              Text('${usagePercent.toStringAsFixed(0)}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: barColor)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: usagePercent / 100, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(barColor), minHeight: 8)),
          const SizedBox(height: 6),
          Row(children: [
            Text('Còn ${formatCurrency(budget.remainingAmount)}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const Spacer(),
            PopupMenuButton<String>(
              onSelected: (v) { if (v == 'edit') onEdit?.call(); if (v == 'delete') onDelete?.call(); },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: AppTheme.expenseColor))),
              ],
              icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[400]),
            ),
          ]),
        ]),
      ),
    );
  }
}