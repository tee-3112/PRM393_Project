import 'package:flutter/material.dart';
import 'package:quanlythuchi/models/transaction.dart';
import 'package:quanlythuchi/utils/theme.dart';
import 'package:quanlythuchi/utils/currency_formatter.dart';
import 'package:quanlythuchi/data/categories.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const TransactionTile({super.key, required this.transaction, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cat = CategoryInfo.byId(transaction.categoryId);
    final icon = cat?.icon ?? Icons.category;
    final color = transaction.isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: AppTheme.expenseColor, child: const Icon(Icons.delete, color: Colors.white)),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 22)),
          title: Text(transaction.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(transaction.description ?? '', maxLines: 1),
          trailing: Text(formatCurrency(transaction.amount), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        ),
      ),
    );
  }
}