import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuchi/providers/app_provider.dart';
import 'package:quanlythuchi/widgets/budget_card.dart';
import 'package:quanlythuchi/data/categories.dart';
import 'package:quanlythuchi/utils/theme.dart';
import 'package:quanlythuchi/utils/currency_formatter.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final budgets = prov.getBudgets();
      final total = budgets.fold<double>(0, (s, b) => s + b.amount);
      final spent = budgets.fold<double>(0, (s, b) => s + b.spentAmount);
      final warned = budgets.where((b) => b.isWarning).length;

      return RefreshIndicator(onRefresh: () async => prov.refresh(), child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), color: AppTheme.primaryGreen,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () {
              var m = prov.selectedMonth - 1, y = prov.selectedYear;
              if (m < 1) { m = 12; y--; } prov.setMonth(m, y);
            }),
            Text('Tháng ${prov.selectedMonth} năm ${prov.selectedYear}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () {
              var m = prov.selectedMonth + 1, y = prov.selectedYear;
              if (m > 12) { m = 1; y++; } prov.setMonth(m, y);
            }),
          ]),
        )),
        SliverToBoxAdapter(child: Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]), borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Tổng ngân sách', style: TextStyle(color: Colors.white70, fontSize: 13)),
              if (warned > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(10)),
                child: Text('$warned mục sắp hết', style: const TextStyle(color: Colors.white, fontSize: 10))),
            ]),
            const SizedBox(height: 6),
            Text(formatCurrency(total), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: total > 0 ? spent / total : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent), minHeight: 8)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Đã chi: ${formatCurrency(spent)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text('Còn: ${formatCurrency(total - spent)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ]),
        )),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(children: [
            Text('Danh mục', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const Spacer(),
            TextButton.icon(onPressed: () => _add(ctx, prov), icon: const Icon(Icons.add, size: 18), label: const Text('Thêm')),
          ]),
        )),
        if (budgets.isEmpty)
          const SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12), Text('Chưa có ngân sách', style: TextStyle(color: AppTheme.textSecondary)),
          ])))
        else
          ...budgets.map((b) => SliverToBoxAdapter(child: BudgetCard(
            budget: b, onEdit: () => _edit(ctx, prov, b.id, b.amount), onDelete: () => prov.deleteBudget(b.id),
          ))),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ]));
    });
  }

  void _add(BuildContext ctx, AppProvider prov) {
    final ctl = TextEditingController();
    final descCtl = TextEditingController();
    int catId = 6; String catName = 'Ăn uống';
    bool repeat = false;

    showDialog(context: ctx, builder: (d) => StatefulBuilder(builder: (sd, ss) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_balance_wallet, color: AppTheme.primaryGreen, size: 20)),
            const SizedBox(width: 10),
            const Text('Thêm ngân sách', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 18),
          const Text('Danh mục', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(child: DropdownButtonFormField<int>(
              initialValue: catId, isExpanded: true,
              decoration: const InputDecoration(border: InputBorder.none),
              items: CategoryInfo.expense.map((c) => DropdownMenuItem(value: c.id,
                child: Row(children: [
                  Text(CategoryInfo.emoji(c.id), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Icon(c.icon, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(c.id == 15 ? 'Khác' : c.name),
                ]),
              )).toList(),
              onChanged: (v) => ss(() { catId = v!; catName = CategoryInfo.byId(v)?.name ?? ''; }),
            )),
          ),
          if (catId == 15) ...[
            const SizedBox(height: 14),
            const Text('Mô tả thêm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: descCtl, decoration: InputDecoration(
              hintText: 'Nhập nội dung cho danh mục này',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
          ],
          const SizedBox(height: 14),
          const Text('Số tiền', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: ctl, keyboardType: TextInputType.number,
            decoration: InputDecoration(prefixText: '₫ ', hintText: '0',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
          const SizedBox(height: 18),
          const Text('Lặp lại', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Chỉ tháng này'), icon: Icon(Icons.calendar_month, size: 18)),
              ButtonSegment(value: true, label: Text('Tháng này + sau'), icon: Icon(Icons.repeat, size: 18)),
            ],
            selected: {repeat},
            onSelectionChanged: (v) => ss(() => repeat = v.first),
            style: SegmentedButton.styleFrom(selectedBackgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15)),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: TextButton(onPressed: () => Navigator.pop(d), child: const Text('Hủy'))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 44, child: ElevatedButton(
              onPressed: () {
                if (ctl.text.isEmpty) return;
                final amount = double.parse(ctl.text);
                var budgetName = catName;
                if (catId == 15) {
                  budgetName = descCtl.text.trim().isEmpty ? 'Khác' : 'Khác: ${descCtl.text.trim()}';
                }
                prov.addBudget(catId, budgetName, amount, repeat: repeat);
                Navigator.pop(d);
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(repeat ? 'Đã thêm ngân sách cho tháng này và các tháng sau' : 'Đã thêm ngân sách'),
                  backgroundColor: AppTheme.primaryGreen, behavior: SnackBarBehavior.floating,
                ));
              },
              child: const Text('Lưu'),
            ))),
          ]),
        ]),
      ),
    )));
  }

  void _edit(BuildContext ctx, AppProvider prov, int id, double cur) {
    final ctl = TextEditingController(text: cur.toStringAsFixed(0));
    showDialog(context: ctx, builder: (d) => AlertDialog(
      title: const Text('Sửa ngân sách'),
      content: TextField(controller: ctl, decoration: const InputDecoration(labelText: 'Số tiền', prefixText: '₫ '), keyboardType: TextInputType.number),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Hủy')),
        TextButton(onPressed: () { prov.deleteBudget(id); Navigator.pop(d); }, child: const Text('Xóa', style: TextStyle(color: AppTheme.expenseColor))),
        ElevatedButton(onPressed: () { if (ctl.text.isEmpty) return; prov.updateBudget(id, double.parse(ctl.text)); Navigator.pop(d); }, child: const Text('Lưu')),
      ],
    ));
  }
}