import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuchi/providers/app_provider.dart';
import 'package:quanlythuchi/widgets/summary_card.dart';
import 'package:quanlythuchi/widgets/transaction_tile.dart';
import 'package:quanlythuchi/widgets/day_selector.dart';
import 'package:quanlythuchi/utils/theme.dart';
import 'package:quanlythuchi/data/categories.dart';
import 'package:quanlythuchi/models/transaction.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  void _showAddDialog(BuildContext ctx) {
    final cats = CategoryInfo.income;
    int selId = cats.first.id;
    String selName = cats.first.name;
    final amCtl = TextEditingController();
    final deCtl = TextEditingController();
    DateTime date = DateTime.now();
    final fk = GlobalKey<FormState>();

    showDialog(context: ctx, builder: (d) => StatefulBuilder(builder: (sd, ss) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(key: fk, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.incomeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.trending_up, color: AppTheme.incomeColor, size: 20)),
                const SizedBox(width: 10), const Text('Thêm khoản thu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ]),
              IconButton(onPressed: () => Navigator.pop(d), icon: const Icon(Icons.close), visualDensity: VisualDensity.compact),
            ]),
            const SizedBox(height: 16),
            TextFormField(controller: amCtl, decoration: const InputDecoration(labelText: 'Số tiền', prefixText: '₫ ', prefixIcon: Icon(Icons.monetization_on_outlined)),
              keyboardType: TextInputType.number, autofocus: true, validator: (v) => v == null || v.isEmpty ? 'Nhập số tiền' : null),
            const SizedBox(height: 14),
            const Text('Danh mục', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Column(children: cats.map((c) => GestureDetector(
                onTap: () => ss(() { selId = c.id; selName = c.name; }),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(color: selId == c.id ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10),
                    boxShadow: selId == c.id ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null),
                  child: Row(children: [
                    Icon(c.icon, size: 20, color: selId == c.id ? AppTheme.incomeColor : AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Text(c.name, style: TextStyle(fontWeight: selId == c.id ? FontWeight.w600 : FontWeight.normal, color: selId == c.id ? AppTheme.textPrimary : AppTheme.textSecondary)),
                    const Spacer(), if (selId == c.id) const Icon(Icons.check, size: 18, color: AppTheme.incomeColor),
                  ]),
                ),
              )).toList()),
            ),
            const SizedBox(height: 14),
            TextFormField(controller: deCtl, decoration: const InputDecoration(labelText: 'Mô tả', prefixIcon: Icon(Icons.notes))),
            const SizedBox(height: 10),
            InkWell(onTap: () async {
              final p = await showDatePicker(context: d, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)), locale: const Locale('vi'));
              if (p != null) ss(() => date = p);
            }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
              child: Row(children: [const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary), const SizedBox(width: 10), Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(color: AppTheme.textPrimary))]),
            )),
            const SizedBox(height: 18),
            SizedBox(height: 46, child: ElevatedButton(onPressed: () {
              if (!fk.currentState!.validate()) return;
              ctx.read<AppProvider>().addTransaction(TransactionType.income, double.parse(amCtl.text), selId, selName, description: deCtl.text, date: date);
              Navigator.pop(d);
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Đã thêm khoản thu'), backgroundColor: AppTheme.incomeColor, behavior: SnackBarBehavior.floating));
            }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.incomeColor),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check, size: 18), SizedBox(width: 8), Text('Thêm khoản thu')])),
            ),
          ])),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final txs = prov.getTransactions(type: 'income');
      final total = txs.fold<double>(0, (s, t) => s + t.amount);
      final d = prov.selectedDay, m = prov.selectedMonth, y = prov.selectedYear;

      void prevDay() {
        var dt = DateTime(y, m, d).subtract(const Duration(days: 1));
        prov.setDay(dt.day);
        if (dt.month != m || dt.year != y) prov.setMonth(dt.month, dt.year);
      }
      void nextDay() {
        var dt = DateTime(y, m, d).add(const Duration(days: 1));
        prov.setDay(dt.day);
        if (dt.month != m || dt.year != y) prov.setMonth(dt.month, dt.year);
      }

      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: DaySelector(day: d, month: m, year: y, onPrevious: prevDay, onNext: nextDay)),
          SliverToBoxAdapter(child: SummaryCard(title: 'Thu nhập ngày', amount: total, count: txs.length, color: AppTheme.incomeColor, darkColor: const Color(0xFF2E7D32))),
          if (txs.isEmpty)
            const SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.trending_up, size: 48, color: AppTheme.textSecondary), SizedBox(height: 12), Text('Chưa có khoản thu nào', style: TextStyle(color: AppTheme.textSecondary)),
            ])))
          else ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('${txs.length} giao dịch', style: TextStyle(fontSize: 13, color: Colors.grey[500])))),
            SliverList(delegate: SliverChildBuilderDelegate((_, i) => TransactionTile(transaction: txs[i], onDelete: () => prov.deleteTransaction(txs[i].id)), childCount: txs.length)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ]),
        floatingActionButton: FloatingActionButton(heroTag: 'income_fab', onPressed: () => _showAddDialog(ctx), child: const Icon(Icons.add)),
      );
    });
  }
}