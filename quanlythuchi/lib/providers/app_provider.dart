import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../data/database.dart';

class AppProvider extends ChangeNotifier {
  final Database _db = Database();
  User? _currentUser;
  int _selectedDay = DateTime.now().day;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  int get userId => _currentUser?.id ?? 0;
  int get selectedDay => _selectedDay;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  Future<void> init() async {
    await _db.init();
    notifyListeners();
  }

  // Auth
  Future<bool> login(String username, String password) async {
    final user = _db.login(username, password);
    if (user == null) return false;
    _currentUser = user;
    notifyListeners();
    return true;
  }

  Future<String?> register(String username, String email, String fullName, String password) async {
    if (username.isEmpty || email.isEmpty || fullName.isEmpty || password.isEmpty) return 'Vui lòng điền đầy đủ thông tin';
    final user = await _db.register(username, email, fullName, password);
    if (user == null) return 'Tên đăng nhập đã tồn tại';
    _currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void setDay(int d) { _selectedDay = d; notifyListeners(); }
  void setMonth(int m, int y) { _selectedMonth = m; _selectedYear = y; notifyListeners(); }

  List<Transaction> getTransactions({int? day, int? month, int? year, String? type}) =>
      _db.getTransactions(userId: userId, day: day ?? _selectedDay, month: month ?? _selectedMonth, year: year ?? _selectedYear, type: type);

  Future<Transaction> addTransaction(TransactionType type, double amount, int categoryId, String categoryName, {String? description, DateTime? date}) async {
    final t = await _db.addTransaction(userId, type, amount, categoryId, categoryName, description: description, date: date);
    notifyListeners(); return t;
  }

  Future<void> deleteTransaction(int id) async { await _db.deleteTransaction(id); notifyListeners(); }

  Map<String, dynamic> getMonthlySummary() => _db.getMonthlySummary(userId, _selectedMonth, _selectedYear);
  List<Map<String, dynamic>> getDailySummaries() => _db.getDailySummaries(userId, _selectedMonth, _selectedYear);
  Map<String, dynamic> getCategorySummaries() => _db.getCategorySummaries(userId, _selectedMonth, _selectedYear);

  // Multi-period
  Map<String, dynamic> getPeriodSummary(int monthsBack) =>
      _db.getPeriodSummary(userId, _selectedMonth, _selectedYear, monthsBack);
  Map<String, dynamic> getCategorySummariesByPeriod(int monthsBack) =>
      _db.getCategorySummariesByPeriod(userId, _selectedMonth, _selectedYear, monthsBack);

  List<Budget> getBudgets() => _db.getBudgets(userId, _selectedMonth, _selectedYear);

  Future<Budget?> addBudget(int categoryId, String categoryName, double amount, {bool repeat = false}) async {
    final b = await _db.addBudget(userId, categoryId, categoryName, _selectedMonth, _selectedYear, amount);
    if (b != null && repeat) {
      for (var i = 1; i <= 11; i++) {
        var nm = _selectedMonth + i; var ny = _selectedYear;
        while (nm > 12) { nm -= 12; ny++; }
        _db.addBudget(userId, categoryId, categoryName, nm, ny, amount);
      }
    }
    notifyListeners(); return b;
  }
  Future<void> updateBudget(int id, double amount) async { await _db.updateBudget(id, amount); notifyListeners(); }
  Future<void> deleteBudget(int id) async { await _db.deleteBudget(id); notifyListeners(); }
  void refresh() { notifyListeners(); }
}
