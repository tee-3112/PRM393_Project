import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:quanlythuchi/providers/app_provider.dart";
import "package:quanlythuchi/screens/dashboard_screen.dart";
import "package:quanlythuchi/screens/income_screen.dart";
import "package:quanlythuchi/screens/expense_screen.dart";
import "package:quanlythuchi/screens/calendar_screen.dart";
import "package:quanlythuchi/screens/budget_screen.dart";
import "package:quanlythuchi/screens/login_screen.dart";
import "package:quanlythuchi/utils/theme.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  static const _titles = ["Thống kê", "Thu nhập", "Chi tiêu", "Lịch", "Ngân sách"];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final user = prov.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            onSelected: (v) {
              if (v == "logout") { prov.logout(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }
            },
            child: Padding(padding: const EdgeInsets.only(right: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(user?.fullName ?? "", style: const TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(width: 6),
                CircleAvatar(radius: 14, backgroundColor: Colors.white.withValues(alpha: 0.2), child: const Icon(Icons.person, size: 16, color: Colors.white)),
              ]),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(value: "info", enabled: false, child: Text(user?.fullName ?? "", style: const TextStyle(fontWeight: FontWeight.w600))),
              const PopupMenuDivider(),
              PopupMenuItem(value: "logout", child: const ListTile(leading: Icon(Icons.logout, color: AppTheme.expenseColor), title: Text("Đăng xuất", style: TextStyle(color: AppTheme.expenseColor)), dense: true, contentPadding: EdgeInsets.zero)),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: const [
        DashboardScreen(), IncomeScreen(), ExpenseScreen(), CalendarScreen(), BudgetScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        height: 65,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: "Thống kê"),
          NavigationDestination(icon: Icon(Icons.trending_up_rounded), label: "Thu nhập"),
          NavigationDestination(icon: Icon(Icons.trending_down_rounded), label: "Chi tiêu"),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: "Lịch"),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: "Ngân sách"),
        ],
      ),
    );
  }
}
