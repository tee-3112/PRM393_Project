import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

class Database {
  static final Database _instance = Database._();
  factory Database() => _instance;
  Database._();

  List<User> _users = [];
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  int _nextTxId = 1;
  int _nextBudgetId = 1;
  bool _initialized = false;

  bool get isReady => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    await _load();
    if (_users.isEmpty) _seed();
    _initialized = true;
  }

  void _seed() {
    final pw = _hashPassword('123456');
    _users = [User(id: 1, username: 'demo', email: 'demo@example.com', fullName: 'Nguyễn Văn A', passwordHash: pw)];

    final now = DateTime.now();
    final m = now.month, y = now.year;
    final pm = m == 1 ? 12 : m - 1, py = m == 1 ? y - 1 : y;
    final pm2 = pm == 1 ? 12 : pm - 1, py2 = pm == 1 ? py - 1 : py;

    _transactions = [
      // Current month
      Transaction(id: 1, userId: 1, type: TransactionType.income, amount: 8000000, categoryId: 1, categoryName: 'Lương', description: 'Lương tháng', date: DateTime(y, m, 5)),
      Transaction(id: 2, userId: 1, type: TransactionType.income, amount: 500000, categoryId: 2, categoryName: 'Thưởng', description: 'Thưởng dự án', date: DateTime(y, m, 10)),
      Transaction(id: 3, userId: 1, type: TransactionType.income, amount: 2000000, categoryId: 4, categoryName: 'Làm thêm', description: 'Freelance', date: DateTime(y, m, 15)),
      Transaction(id: 4, userId: 1, type: TransactionType.expense, amount: 3000000, categoryId: 10, categoryName: 'Nhà ở', description: 'Tiền thuê nhà', date: DateTime(y, m, 1)),
      Transaction(id: 5, userId: 1, type: TransactionType.expense, amount: 85000, categoryId: 6, categoryName: 'Ăn uống', description: 'Ăn trưa', date: DateTime(y, m, 2)),
      Transaction(id: 6, userId: 1, type: TransactionType.expense, amount: 500000, categoryId: 14, categoryName: 'Hóa đơn', description: 'Tiền điện nước', date: DateTime(y, m, 3)),
      Transaction(id: 7, userId: 1, type: TransactionType.expense, amount: 350000, categoryId: 7, categoryName: 'Quần áo', description: 'Áo sơ mi', date: DateTime(y, m, 8)),
      Transaction(id: 8, userId: 1, type: TransactionType.expense, amount: 200000, categoryId: 12, categoryName: 'Giải trí', description: 'Xem phim', date: DateTime(y, m, 12)),
      // Previous month
      Transaction(id: 9, userId: 1, type: TransactionType.income, amount: 8000000, categoryId: 1, categoryName: 'Lương', description: 'Lương tháng trước', date: DateTime(py, pm, 5)),
      Transaction(id: 10, userId: 1, type: TransactionType.expense, amount: 3000000, categoryId: 10, categoryName: 'Nhà ở', description: 'Tiền thuê nhà', date: DateTime(py, pm, 1)),
      Transaction(id: 11, userId: 1, type: TransactionType.expense, amount: 2500000, categoryId: 6, categoryName: 'Ăn uống', description: 'Tổng chi ăn uống', date: DateTime(py, pm, 28)),
      // 2 months ago
      Transaction(id: 12, userId: 1, type: TransactionType.income, amount: 8000000, categoryId: 1, categoryName: 'Lương', description: 'Lương 2 tháng trước', date: DateTime(py2, pm2, 5)),
      Transaction(id: 13, userId: 1, type: TransactionType.expense, amount: 2500000, categoryId: 6, categoryName: 'Ăn uống', description: 'Chi ăn uống', date: DateTime(py2, pm2, 20)),
      Transaction(id: 14, userId: 1, type: TransactionType.expense, amount: 3000000, categoryId: 10, categoryName: 'Nhà ở', description: 'Tiền thuê nhà', date: DateTime(py2, pm2, 1)),
    ];
    _nextTxId = 15;
    _budgets = [
      Budget(id: 1, userId: 1, categoryId: 6, categoryName: 'Ăn uống', month: m, year: y, amount: 3000000),
      Budget(id: 2, userId: 1, categoryId: 7, categoryName: 'Quần áo', month: m, year: y, amount: 1000000),
      Budget(id: 3, userId: 1, categoryId: 8, categoryName: 'Mỹ phẩm', month: m, year: y, amount: 500000),
      Budget(id: 4, userId: 1, categoryId: 9, categoryName: 'Di chuyển', month: m, year: y, amount: 300000),
      Budget(id: 5, userId: 1, categoryId: 10, categoryName: 'Nhà ở', month: m, year: y, amount: 3500000),
      Budget(id: 6, userId: 1, categoryId: 11, categoryName: 'Học tập', month: m, year: y, amount: 500000),
      Budget(id: 7, userId: 1, categoryId: 12, categoryName: 'Giải trí', month: m, year: y, amount: 500000),
      Budget(id: 8, userId: 1, categoryId: 13, categoryName: 'Sức khỏe', month: m, year: y, amount: 400000),
      Budget(id: 9, userId: 1, categoryId: 14, categoryName: 'Hóa đơn', month: m, year: y, amount: 600000),
      Budget(id: 10, userId: 1, categoryId: 15, categoryName: 'Khác (Chi)', month: m, year: y, amount: 300000),
    ];
    _nextBudgetId = 11;
    _save();
  }

  String _hashPassword(String pw) {
    final bytes = utf8.encode(pw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // --- Auth ---
  User? login(String username, String password) {
    final hash = _hashPassword(password);
    try { return _users.firstWhere((u) => u.username == username && u.passwordHash == hash); } catch (_) { return null; }
  }

  Future<User?> register(String username, String email, String fullName, String password) async {
    if (_users.any((u) => u.username == username)) return null;
    final id = _users.isEmpty ? 1 : _users.map((u) => u.id).reduce(max) + 1;
    final user = User(id: id, username: username, email: email, fullName: fullName, passwordHash: _hashPassword(password));
    _users.add(user);
    _save();
    return user;
  }

  User? getUser(int id) { try { return _users.firstWhere((u) => u.id == id); } catch (_) { return null; } }

  // --- CRUD Transactions ---
  List<Transaction> getTransactions({int? userId, int? day, int? month, int? year, String? type}) {
    var list = _transactions.where((t) => userId == null || t.userId == userId).toList();
    if (month != null && year != null) list = list.where((t) => t.date.month == month && t.date.year == year).toList();
    if (day != null) list = list.where((t) => t.date.day == day).toList();
    if (type != null) list = list.where((t) => t.type == (type == 'income' ? TransactionType.income : TransactionType.expense)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<Transaction> addTransaction(int userId, TransactionType type, double amount, int categoryId, String categoryName, {String? description, DateTime? date}) async {
    final t = Transaction(id: _nextTxId++, userId: userId, type: type, amount: amount, categoryId: categoryId, categoryName: categoryName, description: description, date: date ?? DateTime.now());
    _transactions.add(t); await _save(); return t;
  }

  Future<bool> deleteTransaction(int id) async {
    final len = _transactions.length;
    _transactions.removeWhere((t) => t.id == id);
    if (_transactions.length < len) { _save(); return true; }
    return false;
  }

  // --- Dashboard ---
  Map<String, dynamic> getMonthlySummary(int userId, int month, int year) {
    final txs = _transactions.where((t) => t.userId == userId && t.date.month == month && t.date.year == year).toList();
    final inc = txs.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final exp = txs.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
    return {'totalIncome': inc, 'totalExpense': exp, 'balance': inc - exp};
  }

  List<Map<String, dynamic>> getDailySummaries(int userId, int month, int year) {
    final days = DateTime(year, month + 1, 0).day;
    final txs = _transactions.where((t) => t.userId == userId && t.date.month == month && t.date.year == year).toList();
    return List.generate(days, (i) {
      final day = i + 1;
      final dt = txs.where((t) => t.date.day == day).toList();
      final inc = dt.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
      final exp = dt.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
      return {'date': '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}', 'totalIncome': inc, 'totalExpense': exp, 'balance': inc - exp, 'transactions': dt.map((t) => t.toJson()).toList()};
    });
  }

  // --- Category Summaries for Dashboard ---
  Map<String, dynamic> getCategorySummaries(int userId, int month, int year) {
    final txs = _transactions.where((t) => t.userId == userId && t.date.month == month && t.date.year == year).toList();
    final incomeByCat = <String, double>{};
    final expenseByCat = <String, double>{};
    final incomeColorMap = <String, int>{};
    final expenseColorMap = <String, int>{};

    const colors = [0xFF2E7D32, 0xFF1565C0, 0xFFF57C00, 0xFF7B1FA2, 0xFF00897B, 0xFFC62828, 0xFF558B2F, 0xFF283593, 0xFFF4511E, 0xFF6A1B9A, 0xFF00695C, 0xFFE65100, 0xFF4527A0, 0xFF2E7D32, 0xFF1B5E20];

    for (final t in txs) {
      if (t.isIncome) {
        incomeByCat[t.categoryName] = (incomeByCat[t.categoryName] ?? 0) + t.amount;
        if (!incomeColorMap.containsKey(t.categoryName)) {
          incomeColorMap[t.categoryName] = colors[incomeColorMap.length % colors.length];
        }
      } else {
        expenseByCat[t.categoryName] = (expenseByCat[t.categoryName] ?? 0) + t.amount;
        if (!expenseColorMap.containsKey(t.categoryName)) {
          expenseColorMap[t.categoryName] = colors[expenseColorMap.length % colors.length];
        }
      }
    }
    return {
      'incomeByCategory': incomeByCat,
      'expenseByCategory': expenseByCat,
      'incomeColors': incomeColorMap,
      'expenseColors': expenseColorMap,
    };
  }

  // --- Multi-period summaries ---
  Map<String, dynamic> getPeriodSummary(int userId, int month, int year, int monthsBack) {
    final end = DateTime(year, month + 1, 0);
    final start = DateTime(year - (monthsBack ~/ 12), month - (monthsBack % 12), 1);
    final prevStart = DateTime(start.year, start.month - monthsBack, 1);

    double sum(List<Transaction> ts, bool inc) =>
        ts.where((t) => inc ? t.isIncome : t.isExpense).fold<double>(0, (s, t) => s + t.amount);

    final current = _transactions.where((t) =>
        t.userId == userId && t.date.isAfter(start.subtract(const Duration(days: 1))) && t.date.isBefore(end.add(const Duration(days: 1)))).toList();
    final previous = _transactions.where((t) =>
        t.userId == userId && t.date.isAfter(prevStart.subtract(const Duration(days: 1))) && t.date.isBefore(start)).toList();

    final inc = sum(current, true);
    final exp = sum(current, false);
    final prevInc = sum(previous, true);
    final prevExp = sum(previous, false);

    return {
      'totalIncome': inc, 'totalExpense': exp, 'balance': inc - exp,
      'prevIncome': prevInc, 'prevExpense': prevExp,
      'incomePercent': prevInc > 0 ? ((inc - prevInc) / prevInc * 100) : 0.0,
      'expensePercent': prevExp > 0 ? ((exp - prevExp) / prevExp * 100) : 0.0,
    };
  }

  Map<String, dynamic> getCategorySummariesByPeriod(int userId, int month, int year, int monthsBack) {
    final end = DateTime(year, month + 1, 0);
    final start = DateTime(year - (monthsBack ~/ 12), month - (monthsBack % 12), 1);
    final categories = <String, Map<String, dynamic>>{};
    const colors = [0xFF2E7D32, 0xFF1565C0, 0xFFF57C00, 0xFF7B1FA2, 0xFF00897B, 0xFFC62828, 0xFF558B2F, 0xFF283593, 0xFFF4511E, 0xFF6A1B9A, 0xFF00695C, 0xFFE65100, 0xFF4527A0, 0xFF1B5E20, 0xFFAD1457];

    final txs = _transactions.where((t) => t.userId == userId &&
        t.date.isAfter(start.subtract(const Duration(days: 1))) &&
        t.date.isBefore(end.add(const Duration(days: 1)))).toList();

    for (final t in txs) {
      final key = '${t.type == TransactionType.income ? 'inc' : 'exp'}_${t.categoryId}';
      if (!categories.containsKey(key)) {
        categories[key] = {
          'name': t.categoryName,
          'amount': 0.0,
          'type': t.type == TransactionType.income ? 'income' : 'expense',
          'color': colors[categories.length % colors.length],
        };
      }
      categories[key]!['amount'] = (categories[key]!['amount'] as double) + t.amount;
    }

    final incomeList = categories.values.where((c) => c['type'] == 'income')
        .map((c) => Map<String, dynamic>.from(c)).toList()..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    final expenseList = categories.values.where((c) => c['type'] == 'expense')
        .map((c) => Map<String, dynamic>.from(c)).toList()..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return {'incomeCategories': incomeList, 'expenseCategories': expenseList};
  }

  // --- Budgets ---
  List<Budget> getBudgets(int userId, int month, int year) {
    final txs = _transactions.where((t) => t.userId == userId && t.isExpense && t.date.month == month && t.date.year == year).toList();
    return _budgets.where((b) => b.userId == userId && b.month == month && b.year == year).map((b) {
      final spent = txs.where((t) => t.categoryId == b.categoryId).fold<double>(0, (s, t) => s + t.amount);
      return Budget(id: b.id, userId: b.userId, categoryId: b.categoryId, categoryName: b.categoryName, month: b.month, year: b.year, amount: b.amount, spentAmount: spent);
    }).toList();
  }

  Future<Budget?> addBudget(int userId, int categoryId, String categoryName, int month, int year, double amount) async {
    if (_budgets.any((b) => b.userId == userId && b.categoryId == categoryId && b.month == month && b.year == year)) return null;
    final b = Budget(id: _nextBudgetId++, userId: userId, categoryId: categoryId, categoryName: categoryName, month: month, year: year, amount: amount);
    _budgets.add(b); await _save(); return b;
  }

  Future<bool> updateBudget(int id, double amount) async {
    final idx = _budgets.indexWhere((b) => b.id == id);
    if (idx < 0) return false;
    _budgets[idx] = Budget(id: _budgets[idx].id, userId: _budgets[idx].userId, categoryId: _budgets[idx].categoryId, categoryName: _budgets[idx].categoryName, month: _budgets[idx].month, year: _budgets[idx].year, amount: amount);
    await _save(); return true;
  }

  Future<bool> deleteBudget(int id) async {
    final len = _budgets.length;
    _budgets.removeWhere((b) => b.id == id);
    if (_budgets.length < len) { _save(); return true; }
    return false;
  }

  // --- Persistence ---
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('users', jsonEncode(_users.map((u) => u.toJson()).toList()));
    prefs.setString('transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    prefs.setString('budgets', jsonEncode(_budgets.map((b) => b.toJson()).toList()));
    prefs.setInt('nextTxId', _nextTxId);
    prefs.setInt('nextBudgetId', _nextBudgetId);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    final txsJson = prefs.getString('transactions');
    final budgetsJson = prefs.getString('budgets');

    if (usersJson != null) _users = (jsonDecode(usersJson) as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    if (txsJson != null) _transactions = (jsonDecode(txsJson) as List).map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    if (budgetsJson != null) _budgets = (jsonDecode(budgetsJson) as List).map((e) => Budget.fromJson(e as Map<String, dynamic>)).toList();

    _nextTxId = prefs.getInt('nextTxId') ?? 1;
    _nextBudgetId = prefs.getInt('nextBudgetId') ?? 1;
  }
}
