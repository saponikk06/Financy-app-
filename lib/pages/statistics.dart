import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/chart.dart';
import 'package:flutter_application_1/data/transaction_model.dart';
import 'package:flutter_application_1/data/transaction_repository.dart';
import 'package:flutter_application_1/data/account_repository.dart';
import 'package:flutter_application_1/data/account_model.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final List<String> periods = ['День', 'Неделя', 'Месяц', 'Год'];
  int selectedPeriodIndex = 0;
  late List<Transaction> transactions;
  bool showExpenses = true;
  bool sortAscending = true;
  String? selectedAccount;

  final Map<String, String> _categoryImages = {
    'Еда': 'food.png',
    'Магазин': 'shop.png',
    'Транспорт': 'transport.png',
    'Досуг': 'leisure.png',
    'Образование': 'education.png',
    'Прочее': 'misc.png',
    'Зарплата': 'salary.png',
    'Перевод': 'transfer.png',
    'Проценты': 'interest.png',
    'Пополнение': 'deposit.png',
  };

  @override
  void initState() {
    super.initState();
    transactions = TransactionRepository.getTransactions();
  }

  List<Transaction> getFilteredTransactions() {
    final now = DateTime.now();
    DateTime startDate;
    switch (periods[selectedPeriodIndex]) {
      case 'День':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Неделя':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Месяц':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Год':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        startDate = DateTime(2000);
    }

    var filtered = transactions.where((t) {
      try {
        final parts = t.time.split('.');
        if (parts.length != 3) return false;
        final transactionDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        return transactionDate.isAfter(startDate) ||
            transactionDate.isAtSameMomentAs(startDate);
      } catch (_) {
        return false;
      }
    }).toList();

    filtered = filtered.where((t) => t.buy == showExpenses).toList();

    if (selectedAccount != null) {
      filtered =
          filtered.where((t) => t.accountName == selectedAccount).toList();
    }

    filtered.sort((a, b) {
      final aAmount = double.tryParse(a.fee) ?? 0;
      final bAmount = double.tryParse(b.fee) ?? 0;
      return sortAscending
          ? aAmount.compareTo(bAmount)
          : bAmount.compareTo(aAmount);
    });

    return filtered;
  }

  String calculateTotal() {
    final filtered = getFilteredTransactions();
    double total = 0;
    for (var transaction in filtered) {
      final amount = double.tryParse(transaction.fee) ?? 0;
      total += amount;
    }
    return '${showExpenses ? '-' : '+'}${total.toStringAsFixed(2)} ₽';
  }

  void _showCategoryBreakdown(BuildContext context) {
    final filtered = getFilteredTransactions();

    final Map<String, double> categoryTotals = {};
    for (var transaction in filtered) {
      final category = transaction.category;
      final amount = double.tryParse(transaction.fee) ?? 0;
      categoryTotals.update(category, (value) => value + amount,
          ifAbsent: () => amount);
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showExpenses ? 'Расходы по категориям' : 'Доходы по категориям',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ...sortedEntries.map((entry) {
                final image = _categoryImages[entry.key] ?? 'cash.png';
                return ListTile(
                  leading: Image.asset(
                    'images/$image',
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.category),
                  ),
                  title: Text(entry.key),
                  trailing: Text('${entry.value.toStringAsFixed(2)} ₽'),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = getFilteredTransactions();
    final accounts = AccountRepository.getAccounts();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Статистика',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: periods.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 15),
                            itemBuilder: (context, index) => ChoiceChip(
                              label: Text(periods[index]),
                              selected: selectedPeriodIndex == index,
                              selectedColor: Colors.teal,
                              labelStyle: TextStyle(
                                color: selectedPeriodIndex == index
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onSelected: (_) {
                                setState(() => selectedPeriodIndex = index);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedAccount,
                          hint: const Text('Все счета'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Все счета'),
                            ),
                            ...accounts.map((a) => DropdownMenuItem<String>(
                                  value: a.name,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'images/${a.image}',
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.error),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(a.name),
                                    ],
                                  ),
                                )),
                          ],
                          onChanged: (value) =>
                              setState(() => selectedAccount = value),
                          underline: const SizedBox(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: Colors.teal,
                              ),
                              onPressed: () => setState(
                                  () => sortAscending = !sortAscending),
                            ),
                            TextButton.icon(
                              onPressed: () => _showCategoryBreakdown(context),
                              icon: const Icon(Icons.pie_chart,
                                  color: Colors.teal),
                              label: const Text(
                                'По категориям',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => showExpenses = !showExpenses),
                              child: Container(
                                width: 120,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      showExpenses ? 'Расходы' : 'Доходы',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      showExpenses
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: Chart(
                            filteredTransactions: filteredTransactions,
                            period: periods[selectedPeriodIndex],
                            showExpenses: showExpenses,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                showExpenses ? 'Топ расходы' : 'Топ доходы',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.swap_vert,
                                    color: Colors.grey),
                                onPressed: () => setState(
                                    () => sortAscending = !sortAscending),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = filteredTransactions[index];
                      final formattedAmount = '${t.buy ? '-' : '+'}${t.fee} ₽';
                      final cardColor =
                          t.buy ? Colors.red[50] : Colors.green[50];
                      final amountColor = t.buy ? Colors.red : Colors.green;
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              t.image,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Image.asset('images/cash.png'),
                            ),
                          ),
                          title: Text(t.name),
                          subtitle: Text(t.time),
                          trailing: Text(
                            formattedAmount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: amountColor,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredTransactions.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Итого ${showExpenses ? 'трат' : 'доходов'} за ${periods[selectedPeriodIndex].toLowerCase()}: ${calculateTotal()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
