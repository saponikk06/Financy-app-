import 'package:flutter/material.dart';
import '../pages/home.dart';
import '../pages/statistics.dart';
import '../pages/add.dart';
import '../pages/accounts.dart';
import '../pages/profile.dart';
import '../data/transaction_model.dart';
import '../data/transaction_repository.dart';
import '../data/user_repository.dart';

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int _selectedIndex = 0;
  final double _iconSize = 32.0;

  final List<Widget> _screens = [
    const Home(),
    const Statistics(),
    const Accounts(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddScreen(context),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xff368983),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(0),
                  child: Icon(
                    Icons.home,
                    size: _iconSize,
                    color: _selectedIndex == 0 ? const Color(0xff368983) : Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(1),
                  child: Icon(
                    Icons.bar_chart,
                    size: _iconSize,
                    color: _selectedIndex == 1 ? const Color(0xff368983) : Colors.grey,
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: _iconSize,
                    color: _selectedIndex == 2 ? const Color(0xff368983) : Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(3),
                  child: Icon(
                    Icons.person,
                    size: _iconSize,
                    color: _selectedIndex == 3 ? const Color(0xff368983) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddScreen(BuildContext context) async {
    final newTransaction = await Navigator.of(context).push<Transaction>(
      MaterialPageRoute(
        builder: (context) => AddScreen(
          expenseCategories: ['Еда', 'Магазин', 'Транспорт', 'Досуг', 'Образование', 'Прочее'],
          incomeCategories: ['Зарплата', 'Перевод', 'Проценты', 'Пополнение'],
          transactions: TransactionRepository.getTransactions(),
        ),
      ),
    );

    if (newTransaction != null) {
      TransactionRepository.addTransaction(newTransaction);
      setState(() {
        // Обновляем все страницы, включая Home, чтобы отразить новую транзакцию
      });
    }
  }

  @override
  void didUpdateWidget(Bottom oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем Home при возврате с Profile, если данные пользователя изменились
    setState(() {
      // Это заставит Home перезагрузить данные пользователя
    });
  }
}