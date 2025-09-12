// # Flutter MVC Daily Expense & Income Tracker

// This single document contains a complete, ready-to-copy **Flutter MVC app**. Copy each file into your project (matching paths) and run `flutter pub get` then `flutter run`.

// ---

// ## Project structure

// ```
// finance_app/
// ├ pubspec.yaml
// └ lib/
//   ├ main.dart
//   ├ models/
//   │  └ transaction_model.dart
//   ├ services/
//   │  └ db_helper.dart
//   ├ controllers/
//   │  └ transaction_controller.dart
//   ├ views/
//   │  ├ home_screen.dart
//   │  ├ add_transaction_screen.dart
//   │  └ stats_screen.dart
//   └ widgets/
//      ├ transaction_tile.dart
//      └ simple_chart.dart
// ```

// ---

// # pubspec.yaml

// ```yaml
// name: finance_app
// description: A Flutter MVC daily expense & income tracker
// publish_to: 'none'
// version: 1.0.0+1
// environment:
//   sdk: '>=2.18.0 <4.0.0'

// dependencies:
//   flutter:
//     sdk: flutter
//   provider: ^6.0.5
//   sqflite: ^2.2.8
//   path_provider: ^2.0.15
//   path: ^1.8.3
//   intl: ^0.18.1
//   fl_chart: ^0.55.1

// flutter:
//   uses-material-design: true
// ```

// ---

// # lib/main.dart

// ```dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'controllers/transaction_controller.dart';
// import 'views/home_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => TransactionController()..loadTransactions(),
//       child: MaterialApp(
//         title: 'Daily Finance',
//         theme: ThemeData(primarySwatch: Colors.indigo),
//         home: const HomeScreen(),
//       ),
//     );
//   }
// }
// ```

// ---

// # lib/models/transaction_model.dart

// ```dart
// enum TransactionSource { manual, telebirr, bank }

// enum TransactionType { expense, income }

// class TransactionModel {
//   int? id;
//   String title;
//   double amount;
//   DateTime date;
//   String category;
//   TransactionType type;
//   TransactionSource source;

//   TransactionModel({
//     this.id,
//     required this.title,
//     required this.amount,
//     required this.date,
//     required this.category,
//     required this.type,
//     this.source = TransactionSource.manual,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'amount': amount,
//       'date': date.toIso8601String(),
//       'category': category,
//       'type': type == TransactionType.income ? 1 : 0,
//       'source': _sourceToInt(source),
//     };
//   }

//   factory TransactionModel.fromMap(Map<String, dynamic> m) {
//     return TransactionModel(
//       id: m['id'] as int?,
//       title: m['title'] as String,
//       amount: (m['amount'] as num).toDouble(),
//       date: DateTime.parse(m['date'] as String),
//       category: m['category'] as String,
//       type: (m['type'] as int) == 1 ? TransactionType.income : TransactionType.expense,
//       source: _intToSource(m['source'] as int? ?? 0),
//     );
//   }

//   static int _sourceToInt(TransactionSource s) {
//     switch (s) {
//       case TransactionSource.telebirr:
//         return 1;
//       case TransactionSource.bank:
//         return 2;
//       case TransactionSource.manual:
//       default:
//         return 0;
//     }
//   }

//   static TransactionSource _intToSource(int i) {
//     switch (i) {
//       case 1:
//         return TransactionSource.telebirr;
//       case 2:
//         return TransactionSource.bank;
//       case 0:
//       default:
//         return TransactionSource.manual;
//     }
//   }
// }
// ```

// ---

// # lib/services/db_helper.dart

// ```dart
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import '../models/transaction_model.dart';

// class DBHelper {
//   DBHelper._privateConstructor();
//   static final DBHelper instance = DBHelper._privateConstructor();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final documentsDirectory = await getApplicationDocumentsDirectory();
//     final path = join(documentsDirectory.path, 'finance_app.db');
//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE transactions(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         title TEXT NOT NULL,
//         amount REAL NOT NULL,
//         date TEXT NOT NULL,
//         category TEXT NOT NULL,
//         type INTEGER NOT NULL,
//         source INTEGER NOT NULL
//       )
//     ''');
//   }

//   Future<int> insertTransaction(TransactionModel t) async {
//     final db = await database;
//     return await db.insert('transactions', t.toMap());
//   }

//   Future<int> updateTransaction(TransactionModel t) async {
//     final db = await database;
//     return await db.update('transactions', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
//   }

//   Future<int> deleteTransaction(int id) async {
//     final db = await database;
//     return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<List<TransactionModel>> getAllTransactions() async {
//     final db = await database;
//     final res = await db.query('transactions', orderBy: 'date DESC');
//     return res.map((m) => TransactionModel.fromMap(m)).toList();
//   }

//   Future<void> close() async {
//     final db = await database;
//     await db.close();
//   }
// }
// ```

// ---

// # lib/controllers/transaction_controller.dart

// ```dart
// import 'package:flutter/foundation.dart';
// import '../models/transaction_model.dart';
// import '../services/db_helper.dart';

// class TransactionController extends ChangeNotifier {
//   final DBHelper _db = DBHelper.instance;

//   List<TransactionModel> _transactions = [];
//   bool _isLoading = false;

//   List<TransactionModel> get transactions => _transactions;
//   bool get isLoading => _isLoading;

//   double get totalIncome =>
//       _transactions.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);

//   double get totalExpense =>
//       _transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);

//   double get balance => totalIncome - totalExpense;

//   Future<void> loadTransactions() async {
//     _isLoading = true;
//     notifyListeners();
//     _transactions = await _db.getAllTransactions();
//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> addTransaction(TransactionModel t) async {
//     await _db.insertTransaction(t);
//     await loadTransactions();
//   }

//   Future<void> updateTransaction(TransactionModel t) async {
//     if (t.id == null) return;
//     await _db.updateTransaction(t);
//     await loadTransactions();
//   }

//   Future<void> deleteTransaction(int id) async {
//     await _db.deleteTransaction(id);
//     await loadTransactions();
//   }

//   // Prepare recent daily totals for the last [days] days. Useful for charts.
//   List<Map<String, dynamic>> recentDailyTotals({int days = 7}) {
//     final now = DateTime.now();
//     final List<Map<String, dynamic>> ret = [];
//     for (int i = days - 1; i >= 0; i--) {
//       final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
//       final dayStart = day;
//       final dayEnd = day.add(Duration(days: 1));
//       final dayTransactions = _transactions.where((t) => t.date.isAfter(dayStart.subtract(Duration(seconds: 1))) && t.date.isBefore(dayEnd));
//       final income = dayTransactions.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
//       final expense = dayTransactions.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
//       ret.add({'date': day, 'income': income, 'expense': expense});
//     }
//     return ret;
//   }

//   // Placeholder: sync Telebirr transactions. Implement API calls here later.
//   Future<void> syncTelebirrTransactions(List<TransactionModel> fetched) async {
//     // example: deduplicate (by date+amount+source) and insert
//     for (final t in fetched) {
//       // naive dedupe: check if same amount and same date exists
//       final exists = _transactions.any((e) => e.amount == t.amount && e.date.toIso8601String() == t.date.toIso8601String() && e.source == t.source);
//       if (!exists) {
//         await _db.insertTransaction(t);
//       }
//     }
//     await loadTransactions();
//   }
// }
// ```

// ---

// # lib/views/home_screen.dart

// ```dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controllers/transaction_controller.dart';
// import '../views/add_transaction_screen.dart';
// import '../widgets/transaction_tile.dart';
// import '../widgets/simple_chart.dart';
// import 'stats_screen.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Provider.of<TransactionController>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Daily Expense Tracker'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync),
//             tooltip: 'Sync Telebirr (placeholder)',
//             onPressed: () {
//               // Placeholder: you'll call controller.syncTelebirrTransactions after you implement API.
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Telebirr sync not implemented yet')));
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.bar_chart),
//             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
//       ),
//       body: ctrl.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     children: [
//                       Text('Balance: ${NumberFormat.simpleCurrency().format(ctrl.balance)}', style: const TextStyle(fontSize: 20)),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Column(children: [const Text('Income'), Text(NumberFormat.simpleCurrency().format(ctrl.totalIncome))]),
//                           Column(children: [const Text('Expense'), Text(NumberFormat.simpleCurrency().format(ctrl.totalExpense))]),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 200, child: SimpleChart(data: ctrl.recentDailyTotals())),
//                 const Divider(),
//                 Expanded(
//                   child: ctrl.transactions.isEmpty
//                       ? const Center(child: Text('No transactions yet'))
//                       : ListView.builder(
//                           itemCount: ctrl.transactions.length,
//                           itemBuilder: (ctx, i) {
//                             final t = ctrl.transactions[i];
//                             return TransactionTile(
//                               t: t,
//                               onDelete: () => ctrl.deleteTransaction(t.id!),
//                               onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(edit: t))),
//                             );
//                           },
//                         ),
//                 )
//               ],
//             ),
//     );
//   }
// }
// ```

// ---

// # lib/views/add_transaction_screen.dart

// ```dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/transaction_model.dart';
// import '../controllers/transaction_controller.dart';
// import 'package:intl/intl.dart';

// class AddTransactionScreen extends StatefulWidget {
//   final TransactionModel? edit;
//   const AddTransactionScreen({Key? key, this.edit}) : super(key: key);

//   @override
//   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
// }

// class _AddTransactionScreenState extends State<AddTransactionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late String _title;
//   late double _amount;
//   DateTime _date = DateTime.now();
//   String _category = 'General';
//   TransactionType _type = TransactionType.expense;
//   TransactionSource _source = TransactionSource.manual;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.edit != null) {
//       _title = widget.edit!.title;
//       _amount = widget.edit!.amount;
//       _date = widget.edit!.date;
//       _category = widget.edit!.category;
//       _type = widget.edit!.type;
//       _source = widget.edit!.source;
//     } else {
//       _title = '';
//       _amount = 0.0;
//     }
//   }

//   void _save() {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();
//     final controller = Provider.of<TransactionController>(context, listen: false);
//     final t = TransactionModel(
//       id: widget.edit?.id,
//       title: _title,
//       amount: _amount,
//       date: _date,
//       category: _category,
//       type: _type,
//       source: _source,
//     );

//     if (widget.edit == null) {
//       controller.addTransaction(t);
//     } else {
//       controller.updateTransaction(t);
//     }
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.edit == null ? 'Add Transaction' : 'Edit Transaction')),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 initialValue: _title,
//                 decoration: const InputDecoration(labelText: 'Title'),
//                 validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 onSaved: (v) => _title = v!.trim(),
//               ),
//               TextFormField(
//                 initialValue: widget.edit != null ? widget.edit!.amount.toString() : '',
//                 decoration: const InputDecoration(labelText: 'Amount'),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter a number' : null,
//                 onSaved: (v) => _amount = double.parse(v!),
//               ),
//               Row(
//                 children: [
//                   Expanded(child: Text('Date: ${DateFormat.yMd().format(_date)}')),
//                   TextButton(
//                     child: const Text('Select'),
//                     onPressed: () async {
//                       final selected = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
//                       if (selected != null) setState(() => _date = selected);
//                     },
//                   )
//                 ],
//               ),
//               DropdownButtonFormField<TransactionType>(
//                 value: _type,
//                 items: TransactionType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
//                 onChanged: (v) => setState(() => _type = v!),
//                 decoration: const InputDecoration(labelText: 'Type'),
//               ),
//               DropdownButtonFormField<TransactionSource>(
//                 value: _source,
//                 items: TransactionSource.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
//                 onChanged: (v) => setState(() => _source = v!),
//                 decoration: const InputDecoration(labelText: 'Source'),
//               ),
//               TextFormField(
//                 initialValue: _category,
//                 decoration: const InputDecoration(labelText: 'Category'),
//                 onSaved: (v) => _category = v ?? 'General',
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton(onPressed: _save, child: const Text('Save')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// ```

// ---

// # lib/views/stats_screen.dart

// ```dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controllers/transaction_controller.dart';
// import '../widgets/simple_chart.dart';

// class StatsScreen extends StatelessWidget {
//   const StatsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Provider.of<TransactionController>(context);
//     final data = ctrl.recentDailyTotals(days: 7);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Statistics (Last 7 days)')),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(children: [
//           Text('Income: ${ctrl.totalIncome.toStringAsFixed(2)}'),
//           Text('Expense: ${ctrl.totalExpense.toStringAsFixed(2)}'),
//           const SizedBox(height: 12),
//           SizedBox(height: 250, child: SimpleChart(data: data)),
//         ]),
//       ),
//     );
//   }
// }
// ```

// ---

// # lib/widgets/transaction_tile.dart

// ```dart
// import 'package:flutter/material.dart';
// import '../models/transaction_model.dart';
// import 'package:intl/intl.dart';

// class TransactionTile extends StatelessWidget {
//   final TransactionModel t;
//   final VoidCallback onDelete;
//   final VoidCallback? onEdit;
//   const TransactionTile({Key? key, required this.t, required this.onDelete, this.onEdit}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(child: Text(t.type == TransactionType.income ? '+' : '-')),
//       title: Text(t.title),
//       subtitle: Text('${t.category} • ${DateFormat.yMMMd().format(t.date)} • ${t.source.name}'),
//       trailing: Row(mainAxisSize: MainAxisSize.min, children: [
//         Text(NumberFormat.simpleCurrency().format(t.amount)),
//         IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
//         IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
//       ]),
//     );
//   }
// }
// ```

// ---

// # lib/widgets/simple_chart.dart

// ```dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// class SimpleChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data; // [{date: DateTime, income: double, expense: double}, ...]
//   const SimpleChart({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (data.isEmpty) return const Center(child: Text('No data'));

//     final spotsIncome = <FlSpot>[];
//     final spotsExpense = <FlSpot>[];
//     for (int i = 0; i < data.length; i++) {
//       spotsIncome.add(FlSpot(i.toDouble(), (data[i]['income'] as double)));
//       spotsExpense.add(FlSpot(i.toDouble(), (data[i]['expense'] as double)));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: LineChart(LineChartData(
//         lineBarsData: [
//           LineChartBarData(spots: spotsIncome, isCurved: true, dotData: FlDotData(show: false)),
//           LineChartBarData(spots: spotsExpense, isCurved: true, dotData: FlDotData(show: false)),
//         ],
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
//             final idx = val.toInt();
//             if (idx < 0 || idx >= data.length) return const SizedBox();
//             final d = data[idx]['date'] as DateTime;
//             return Text(DateFormat.Md().format(d), style: const TextStyle(fontSize: 10));
//           })),
//           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
//         ),
//         gridData: FlGridData(show: true),
//         borderData: FlBorderData(show: true),
//       )),
//     );
//   }
// }
// ```

// ---

// # Usage notes

// 1. Copy the files into a new Flutter project matching the paths above.
// 2. Run `flutter pub get` to install dependencies.
// 3. Run the app.
// 4. The Telebirr sync is left as a placeholder: implement API calls and then map responses to `TransactionModel` and call `TransactionController.syncTelebirrTransactions()`.

// ---

// If you want, I can now:
// - Convert this into a downloadable ZIP file, or
// - Add Telebirr API example (auth flow + endpoint mapping), or
// - Refactor the controller to use a repository layer for easier testing.

// Tell me which next step you want.
