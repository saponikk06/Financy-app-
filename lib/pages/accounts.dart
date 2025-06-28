import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/account_model.dart';
import 'package:flutter_application_1/data/account_repository.dart';

class Accounts extends StatefulWidget {
  const Accounts({Key? key}) : super(key: key);

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String? _selectedType;
  final List<String> accountTypes = ['Карта', 'Наличные', 'Банковский счет'];
  final Map<String, String> _typeImages = {
    'Карта': 'card.png',
    'Наличные': 'cash.png',
    'Банковский счет': 'bank.png',
  };

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Добавить счет'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название счета',
                        hintText: 'Например, Основная карта',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Тип счета',
                      ),
                      items: accountTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedType = value;
                        });
                      },
                      hint: const Text('Выберите тип'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Баланс (₽)',
                        hintText: '0.00',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _selectedType != null &&
                        _balanceController.text.isNotEmpty) {
                      double? balance = double.tryParse(_balanceController.text);
                      if (balance != null && balance >= 0) {
                        AccountRepository.addAccount(
                          Account(
                            name: _nameController.text,
                            type: _selectedType!,
                            balance: balance.toStringAsFixed(2),
                            image: _typeImages[_selectedType] ?? 'default.png',
                          ),
                        );
                        setState(() {});
                        _nameController.clear();
                        _balanceController.clear();
                        _selectedType = null;
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Введите корректный баланс')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните все поля')),
                      );
                    }
                  },
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = AccountRepository.getAccounts();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Счета',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showAddAccountDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Добавить счет',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff368983),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ваши счета',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final account = accounts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          'images/${account.image}',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 40,
                            width: 40,
                            color: Colors.grey,
                            child: const Icon(Icons.image_not_supported, size: 20),
                          ),
                        ),
                      ),
                      title: Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        account.type,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        '${account.balance} ₽',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
                childCount: accounts.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}