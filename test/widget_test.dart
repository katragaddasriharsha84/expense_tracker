import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/models/expense.dart';

void main() {
  test('Expense round-trips through a database map', () {
    final e = Expense(
      id: 1,
      title: 'Lunch',
      amount: 250.5,
      category: 'Food',
      date: DateTime(2026, 10, 26, 13),
      note: 'with team',
    );
    final back = Expense.fromMap(e.toMap());
    expect(back.title, 'Lunch');
    expect(back.amount, 250.5);
    expect(back.category, 'Food');
    expect(back.date, e.date);
    expect(back.note, 'with team');
  });

  test('Unknown category falls back to Other', () {
    expect(Category.byName('Nope').name, 'Other');
  });
}
