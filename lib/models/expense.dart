import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;

  const Category(this.name, this.icon, this.color);

  static const all = <Category>[
    Category('Food', Icons.restaurant, Color(0xFFEF6C00)),
    Category('Transport', Icons.directions_car, Color(0xFF1E88E5)),
    Category('Shopping', Icons.shopping_bag, Color(0xFF8E24AA)),
    Category('Bills', Icons.receipt_long, Color(0xFFE53935)),
    Category('Entertainment', Icons.movie, Color(0xFF00897B)),
    Category('Health', Icons.local_hospital, Color(0xFF43A047)),
    Category('Education', Icons.school, Color(0xFF3949AB)),
    Category('Other', Icons.category, Color(0xFF757575)),
  ];

  static Category byName(String name) =>
      all.firstWhere((c) => c.name == name, orElse: () => all.last);
}

class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.millisecondsSinceEpoch,
        'note': note,
      };

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as int,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        note: map['note'] as String?,
      );
}
