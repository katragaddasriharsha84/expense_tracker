import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';

/// Local-only SQLite storage. Nothing leaves the device.
class ExpenseDb {
  ExpenseDb._();
  static final instance = ExpenseDb._();

  Database? _db;

  Future<Database> get database async =>
      _db ??= await openDatabase(
        join(await getDatabasesPath(), 'expenses.db'),
        version: 1,
        onCreate: (db, _) => db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date INTEGER NOT NULL,
            note TEXT
          )
        '''),
      );

  Future<int> insert(Expense e) async =>
      (await database).insert('expenses', e.toMap());

  Future<int> update(Expense e) async => (await database)
      .update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);

  Future<int> delete(int id) async =>
      (await database).delete('expenses', where: 'id = ?', whereArgs: [id]);

  /// Expenses within [month] (only year/month are used), newest first.
  Future<List<Expense>> forMonth(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await (await database).query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }
}
