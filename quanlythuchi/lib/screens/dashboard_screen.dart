import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:quanlythuchi/providers/app_provider.dart';
import 'package:quanlythuchi/utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _touchedInc = -1, _touchedExp = -1;
  bool _showIncome = true;

  String _fmt(double v) {
    final nf = NumberFormat('#,##0', 'vi_VN');
    return nf.format(v.round());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final sum = prov.getMonthlySummary();
    final cats = prov.getCategorySummaries();
    final inc = sum['totalIncome'] as double;
    final exp = sum['totalExpense'] as double;
    final bal = sum['balance'] as double;
    final incCat = cats['incomeByCategory'] as Map<String, double>;
    final expCat = cats['expenseByCategory'] as Map<String, double>;
    final incCol = cats['incomeColors'] as Map<String, int>;
    final expCol = cats['expenseColors'] as Map<String, int>;
    final has = inc > 0 || exp > 0;

    return RefreshIndicator(
      onRefresh: () async => prov.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _monthPicker(prov),
            const SizedBox(height: 14),
            _summaryCards(inc, exp, bal),
            if (has) ...[
              const SizedBox(height: 20),
              _sectionTitle('Danh mục'),
              const SizedBox(height: 10),
              _toggleRow(),
              const SizedBox(height: 14),
              if (_showIncome && inc > 0) _pieChart(incCat, incCol, inc, 'Thu nhập'),
              if (!_showIncome && exp > 0) _pieChart(expCat, expCol, exp, 'Chi tiêu'),
            ],
            if (!has)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.pie_chart_outline_rounded, size: 72, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Chưa có dữ liệu', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
    );
  }

  Widget _monthPicker(AppProvider p) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.primaryGreen),
            onPressed: () {
              var m = p.selectedMonth - 1;
              var y = p.selectedYear;
              if (m < 1) { m = 12; y--; }
              p.setMonth(m, y);
            },
          ),
          SizedBox(
            width: 105,
            child: Center(
              child: Text(
                'Tháng ${p.selectedMonth.toString().padLeft(2, '0')}/${p.selectedYear}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
            onPressed: () {
              var m = p.selectedMonth + 1;
              var y = p.selectedYear;
              if (m > 12) { m = 1; y++; }
              p.setMonth(m, y);
            },
          ),
        ]),
      ),
    );
  }

  Widget _summaryCards(double inc, double exp, double bal) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _summaryCard('Thu nhập', inc, AppTheme.incomeColor, Icons.trending_up_rounded)),
          const SizedBox(width: 10),
          Expanded(child: _summaryCard('Chi tiêu', exp, AppTheme.expenseColor, Icons.trending_down_rounded)),
        ]),
        const SizedBox(height: 10),
        _balanceCard(bal),
      ],
    );
  }

  Widget _summaryCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        FittedBox(
          child: Text(
            '${_fmt(amount)}₫',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ]),
    );
  }

  Widget _balanceCard(double bal) {
    final pos = bal >= 0;
    final fromC = pos ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final toC = pos ? const Color(0xFF43A047) : const Color(0xFFE53935);
    final icon = pos ? Icons.account_balance_wallet_rounded : Icons.warning_amber_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [fromC, toC], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: fromC.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Số dư', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              '${_fmt(bal)}₫',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _toggleRow() {
    return Center(
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: () => setState(() => _showIncome = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _showIncome ? AppTheme.incomeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Thu nhập',
                style: TextStyle(
                  color: _showIncome ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showIncome = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: !_showIncome ? AppTheme.expenseColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Chi tiêu',
                style: TextStyle(
                  color: !_showIncome ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _pieChart(Map<String, double> data, Map<String, int> colMap, double total, String label) {
    if (data.isEmpty) return const SizedBox();
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final tIdx = label == 'Thu nhập' ? _touchedInc : _touchedExp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        SizedBox(
          height: 200,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (e, r) {
                    if (!e.isInterestedForInteractions || r == null || r.touchedSection == null) {
                      setState(() {
                        if (label == 'Thu nhập') { _touchedInc = -1; } else { _touchedExp = -1; }
                      });
                      return;
                    }
                    setState(() {
                      if (label == 'Thu nhập') { _touchedInc = r.touchedSection!.touchedSectionIndex; }
                      else { _touchedExp = r.touchedSection!.touchedSectionIndex; }
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 1,
                centerSpaceRadius: 50,
                sections: List.generate(entries.length, (i) {
                  final pct = (entries[i].value / total) * 100;
                  final hit = i == tIdx;
                  return PieChartSectionData(
                    color: Color(colMap[entries[i].key] ?? 0xFF2E7D32),
                    value: entries[i].value,
                    title: hit ? '${pct.toStringAsFixed(0)}%' : '',
                    radius: hit ? 60.0 : 50.0,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text('${_fmt(total)}₫', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 14),
        _categoryLegend(entries, colMap, total, label),
      ]),
    );
  }

  Widget _categoryLegend(List<MapEntry<String, double>> entries, Map<String, int> colMap, double total, String label) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((e) {
        final pct = (e.value / total) * 100;
        final c = Color(colMap[e.key] ?? 0xFF2E7D32);
        final idx = entries.indexOf(e);
        final tIdx = label == 'Thu nhập' ? _touchedInc : _touchedExp;
        final active = idx == tIdx;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (label == 'Thu nhập') { _touchedInc = idx; } else { _touchedExp = idx; }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: c.withValues(alpha: active ? 0.15 : 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.withValues(alpha: active ? 1.0 : 0.15)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(
                e.key,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.black87 : AppTheme.textPrimary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 3),
              Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
