import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../Model/trancactionModel.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'finance_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        type INTEGER NOT NULL,
        source INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    return await db.insert('transactions', t.toMap());
  }

  Future<int> updateTransaction(TransactionModel t) async {
    final db = await database;
    return await db.update('transactions', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final res = await db.query('transactions', orderBy: 'date DESC');
    return res.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}