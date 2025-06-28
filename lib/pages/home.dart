import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/transaction_repository.dart';
import 'package:flutter_application_1/data/transaction_model.dart';
import 'package:flutter_application_1/data/account_repository.dart';
import 'package:flutter_application_1/data/account_model.dart';
import 'package:flutter_application_1/data/user_repository.dart';
import 'package:flutter_application_1/data/user_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Transaction> transactions;
  final TextEditingController _initialBalanceController =
      TextEditingController();
  bool _hasSetInitialBalance = false;
  String _selectedFilter = 'Все';
  late UserModel _user;

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
    UserRepository.initializeUser();
    _user = UserRepository.getUser();
    transactions = TransactionRepository.getTransactions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialBalance();
    });
  }

  void _checkInitialBalance() async {
    if (!_hasSetInitialBalance && transactions.isEmpty) {
      _showInitialBalanceDialog();
    }
  }

  void _showInitialBalanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Установить начальный баланс'),
          content: TextField(
            controller: _initialBalanceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Введите сумму (₽)',
              hintText: '0.00',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_initialBalanceController.text.isNotEmpty) {
                  double? amount =
                      double.tryParse(_initialBalanceController.text);
                  if (amount != null && amount >= 0) {
                    TransactionRepository.addTransaction(
                      Transaction(
                        image: 'images/default.png',
                        name: 'Начальный баланс',
                        category: 'Прочее',
                        fee: amount.toStringAsFixed(2),
                        time: _formatDate(DateTime.now()),
                        buy: false,
                        accountName: null,
                      ),
                    );
                    setState(() {
                      transactions = TransactionRepository.getTransactions();
                      _hasSetInitialBalance = true;
                    });
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Введите корректную сумму')),
                    );
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Доброе утро';
    } else if (hour >= 11 && hour < 17) {
      return 'Добрый день';
    } else if (hour >= 17 && hour < 21) {
      return 'Добрый вечер';
    } else {
      return 'Доброй ночи';
    }
  }

  List<Transaction> getFilteredTransactions() {
    if (_selectedFilter == 'Все') {
      return transactions;
    } else if (_selectedFilter == 'Траты') {
      return transactions.where((t) => t.buy).toList();
    } else if (_selectedFilter == 'Доходы') {
      return transactions.where((t) => !t.buy).toList();
    } else {
      return transactions.where((t) => t.category == _selectedFilter).toList();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ListTile(
                title: const Text('Все'),
                onTap: () {
                  setState(() {
                    _selectedFilter = 'Все';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Траты'),
                onTap: () {
                  setState(() {
                    _selectedFilter = 'Траты';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Доходы'),
                onTap: () {
                  setState(() {
                    _selectedFilter = 'Доходы';
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Text(
                'Категории',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._categoryImages.keys.map((category) {
                return ListTile(
                  leading: Image.asset(
                    'images/${_categoryImages[category]}',
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint(
                          'Failed to load category image: images/${_categoryImages[category]}, error: $error');
                      return const Icon(Icons.error, size: 24);
                    },
                  ),
                  title: Text(category),
                  onTap: () {
                    setState(() {
                      _selectedFilter = category;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = getFilteredTransactions();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          color: Colors.grey[100], // Фоновый цвет
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      height: 220,
                      decoration: const BoxDecoration(
                        color: Color(0xff368983),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 224, 223, 223),
                                    ),
                                  ),
                                  Text(
                                    _user.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_outlined,
                                      color: Colors.white),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xff3a7c78),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Общий баланс',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Icon(Icons.more_vert, color: Colors.white),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _calculateBalance(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildFinanceItem(
                                      title: 'Доходы',
                                      amount: _calculateIncome(),
                                      icon: Icons.arrow_upward,
                                    ),
                                    _buildFinanceItem(
                                      title: 'Расходы',
                                      amount: _calculateExpense(),
                                      icon: Icons.arrow_downward,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'История операций',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showFilterBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[200],
                          ),
                          child: Text(
                            _selectedFilter,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = filteredTransactions[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          transaction.image,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                                'Failed to load transaction image: ${transaction.image}, error: $error');
                            return Image.asset(
                              'images/default.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      title: Text(
                        transaction.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        transaction.time,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        '${transaction.buy ? '-' : '+'}${transaction.fee} ₽',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                          color: transaction.buy ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: filteredTransactions.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceItem({
    required String title,
    required String amount,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Color(0xff4a8b87),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xffd8d8d8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _calculateBalance() {
    double balance = 0;
    for (var transaction in transactions) {
      final amount = double.tryParse(transaction.fee) ?? 0;
      balance += transaction.buy ? -amount : amount;
    }
    for (var account in AccountRepository.getAccounts()) {
      final amount = double.tryParse(account.balance) ?? 0;
      balance += amount;
    }
    return '${balance.toStringAsFixed(2)} ₽';
  }

  String _calculateIncome() {
    double income = 0;
    for (var transaction in transactions.where((t) => !t.buy)) {
      income += double.tryParse(transaction.fee) ?? 0;
    }
    return '${income.toStringAsFixed(2)} ₽';
  }

  String _calculateExpense() {
    double expense = 0;
    for (var transaction in transactions.where((t) => t.buy)) {
      expense += double.tryParse(transaction.fee) ?? 0;
    }
    return '${expense.toStringAsFixed(2)} ₽';
  }
}
