import 'package:flutter/foundation.dart';
import '../Model/trancactionModel.dart';
import '../Services/db_helper.dart';

class TransactionController extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome =>
      _transactions.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount!);

  double get totalExpense =>
      _transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount!);

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _db.getAllTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await _db.insertTransaction(t);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    if (t.id == null) return;
    await _db.updateTransaction(t);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    await loadTransactions();
  }

  // Prepare recent daily totals for the last [days] days. Useful for charts.
  List<Map<String, dynamic>> recentDailyTotals({int days = 7}) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> ret = [];
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayStart = day;
      final dayEnd = day.add(Duration(days: 1));
      final dayTransactions = _transactions.where((t) => t.date!.isAfter(dayStart.subtract(Duration(seconds: 1))) && t.date!.isBefore(dayEnd));
      final income = dayTransactions.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount!);
      final expense = dayTransactions.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount!);
      ret.add({'date': day, 'income': income, 'expense': expense});
    }
    return ret;
  }

  // Placeholder: sync Telebirr transactions. Implement API calls here later.
  Future<void> syncTelebirrTransactions(List<TransactionModel> fetched) async {
    // example: deduplicate (by date+amount+source) and insert
    for (final t in fetched) {
      // naive dedupe: check if same amount and same date exists
      final exists = _transactions.any((e) => e.amount == t.amount && e.date!.toIso8601String() == t.date!.toIso8601String() && e.source == t.source);
      if (!exists) {
        await _db.insertTransaction(t);
      }
    }
    await loadTransactions();
  }
}