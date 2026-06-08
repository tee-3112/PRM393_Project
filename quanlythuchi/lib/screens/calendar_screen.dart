import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuchi/providers/app_provider.dart';
import 'package:quanlythuchi/utils/theme.dart';
import 'package:quanlythuchi/utils/currency_formatter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Map<String, dynamic>>? _summaries;
  Map<String, dynamic>? _selected;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      _summaries = prov.getDailySummaries();
      final m = prov.selectedMonth, y = prov.selectedYear;
      final days = DateTime(y, m + 1, 0).day;
      final first = DateTime(y, m, 1).weekday % 7;

      double sumF(String f) => _summaries?.fold<double>(0, (s, d) => s + ((d[f] as num?)?.toDouble() ?? 0)) ?? 0;
      Map<String, dynamic>? dayData(int d) {
        try { return _summaries?.firstWhere((s) => DateTime.parse(s['date'] as String).day == d); } catch (_) { return null; }
      }

      void chg(int delta) {
        var nm = m + delta, ny = y;
        if (nm > 12) { nm = 1; ny++; } if (nm < 1) { nm = 12; ny--; }
        prov.setMonth(nm, ny); setState(() => _selected = null);
      }

      return Column(children: [
        Container(padding: const EdgeInsets.symmetric(vertical: 8), color: AppTheme.primaryGreen,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => chg(-1)),
            Text('Tháng $m năm $y', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => chg(1)),
          ]),
        ),
        if (_summaries != null) Container(padding: const EdgeInsets.all(10), color: Colors.white,
          child: Row(children: [
            _chip('Tổng thu', sumF('totalIncome'), AppTheme.incomeColor),
            const SizedBox(width: 6), _chip('Tổng chi', sumF('totalExpense'), AppTheme.expenseColor),
            const SizedBox(width: 6), _chip('Dư', sumF('balance'), AppTheme.primaryGreen),
          ]),
        ),
        Expanded(child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].map((d) =>
              Expanded(child: Text(d, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600], fontSize: 12)))
            ).toList()),
          ),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GridView.builder(physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.9, mainAxisSpacing: 2, crossAxisSpacing: 2),
              itemCount: first + days,
              itemBuilder: (_, i) {
                if (i < first) return const SizedBox();
                final day = i - first + 1;
                final data = dayData(day);
                final isToday = day == DateTime.now().day && m == DateTime.now().month && y == DateTime.now().year;
                final inc = (data?['totalIncome'] as num?)?.toDouble() ?? 0;
                final exp = (data?['totalExpense'] as num?)?.toDouble() ?? 0;
                final ds = '$y-${m.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                final sel = _selected?['date'] == ds;
                return GestureDetector(
                  onTap: () => setState(() => _selected = data),
                  child: Container(
                    decoration: BoxDecoration(color: isToday ? AppTheme.primaryGreen.withValues(alpha: 0.12) : null, borderRadius: BorderRadius.circular(8),
                      border: sel ? Border.all(color: AppTheme.primaryGreen, width: 2) : null),
                    padding: const EdgeInsets.all(2),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('$day', style: TextStyle(fontSize: 13, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? AppTheme.primaryGreen : AppTheme.textPrimary)),
                      if (inc > 0) Text(formatCurrency(inc), style: const TextStyle(fontSize: 7, color: AppTheme.incomeColor, height: 1.1)),
                      if (exp > 0) Text(formatCurrency(exp), style: const TextStyle(fontSize: 7, color: AppTheme.expenseColor, height: 1.1)),
                    ]),
                  ),
                );
              },
            ),
          )),
          if (_selected != null) _buildDetail(_selected!),
        ])),
      ]);
    });
  }

  Widget _chip(String l, double a, Color c) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [Text(l, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(formatCurrency(a), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c))]),
  ));

  Widget _buildDetail(Map<String, dynamic> data) {
    final ds = data['date'] as String;
    final txs = (data['transactions'] as List?) ?? [];
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Text('Ngày ${ds.substring(8, 10)}/${ds.substring(5, 7)}/${ds.substring(0, 4)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(), Text('Thu: ', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            Text(formatCurrency((data['totalIncome'] as num?)?.toDouble() ?? 0), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.incomeColor)),
            const SizedBox(width: 8), Text('Chi: ', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            Text(formatCurrency((data['totalExpense'] as num?)?.toDouble() ?? 0), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.expenseColor)),
          ]),
        ),
        if (txs.isEmpty)
          const Padding(padding: EdgeInsets.all(12), child: Text('Không có giao dịch', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)))
        else
          Flexible(child: ListView.builder(shrinkWrap: true, itemCount: txs.length, itemBuilder: (_, i) {
            final t = txs[i] as Map<String, dynamic>;
            final isInc = t['type'] == 'income';
            return ListTile(dense: true,
              leading: CircleAvatar(radius: 14, backgroundColor: (isInc ? AppTheme.incomeColor : AppTheme.expenseColor).withValues(alpha: 0.1),
                child: Icon(isInc ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: isInc ? AppTheme.incomeColor : AppTheme.expenseColor)),
              title: Text(t['categoryName'] as String? ?? '', style: const TextStyle(fontSize: 13)),
              subtitle: Text(t['description'] as String? ?? '', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              trailing: Text(formatCurrency((t['amount'] as num).toDouble()), style: TextStyle(fontWeight: FontWeight.bold, color: isInc ? AppTheme.incomeColor : AppTheme.expenseColor, fontSize: 12)),
            );
          })),
      ]),
    );
  }
}