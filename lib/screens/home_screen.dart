import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/expense_db.dart';
import '../models/expense.dart';
import 'edit_expense_screen.dart';

final currency = NumberFormat.simpleCurrency(locale: 'en_IN');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  List<Expense> _expenses = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ExpenseDb.instance.forMonth(_month);
    if (!mounted) return;
    setState(() {
      _expenses = list;
      _loading = false;
    });
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    _load();
  }

  double get _total => _expenses.fold(0, (s, e) => s + e.amount);

  Future<void> _openEditor([Expense? expense]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: expense)),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(Expense e) async {
    await ExpenseDb.instance.delete(e.id!);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Deleted "${e.title}"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            await ExpenseDb.instance.insert(e);
            _load();
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Column(
        children: [
          _MonthHeader(
            month: _month,
            total: _total,
            onPrev: () => _shiftMonth(-1),
            onNext: () => _shiftMonth(1),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tab == 0
                    ? _ExpenseList(
                        expenses: _expenses,
                        onTap: _openEditor,
                        onDelete: _delete,
                      )
                    : _StatsView(expenses: _expenses, total: _total),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Summary'),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final double total;
  final VoidCallback onPrev, onNext;

  const _MonthHeader({
    required this.month,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(12),
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Column(
                children: [
                  Text(DateFormat.yMMMM().format(month),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    currency.format(total),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer),
                  ),
                  const Text('Total spent'),
                ],
              ),
            ),
            IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final void Function(Expense) onTap;
  final void Function(Expense) onDelete;

  const _ExpenseList({
    required this.expenses,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses this month.\nTap + to add one.', textAlign: TextAlign.center));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: expenses.length,
      itemBuilder: (context, i) {
        final e = expenses[i];
        final cat = Category.byName(e.category);
        return Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(e),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: cat.color.withValues(alpha: 0.15),
              child: Icon(cat.icon, color: cat.color),
            ),
            title: Text(e.title),
            subtitle: Text(
                '${e.category} · ${DateFormat.MMMd().format(e.date)}'
                '${e.note?.isNotEmpty == true ? ' · ${e.note}' : ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            trailing: Text(currency.format(e.amount),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => onTap(e),
          ),
        );
      },
    );
  }
}

class _StatsView extends StatelessWidget {
  final List<Expense> expenses;
  final double total;

  const _StatsView({required this.expenses, required this.total});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No data for this month.'));
    }
    final byCat = <String, double>{};
    for (final e in expenses) {
      byCat[e.category] = (byCat[e.category] ?? 0) + e.amount;
    }
    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        SizedBox(
          height: 220,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 50,
            sections: [
              for (final en in entries)
                PieChartSectionData(
                  value: en.value,
                  color: Category.byName(en.key).color,
                  radius: 55,
                  title: '${(en.value / total * 100).round()}%',
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
            ],
          )),
        ),
        for (final en in entries)
          ListTile(
            leading: Icon(Category.byName(en.key).icon,
                color: Category.byName(en.key).color),
            title: Text(en.key),
            subtitle: LinearProgressIndicator(
              value: en.value / total,
              color: Category.byName(en.key).color,
            ),
            trailing: Text(currency.format(en.value)),
          ),
      ],
    );
  }
}
