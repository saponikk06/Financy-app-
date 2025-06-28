import 'package:flutter/material.dart';
import '../data/transaction_model.dart';
import '../data/account_repository.dart';
import '../data/account_model.dart';

class AddScreen extends StatefulWidget {
  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final List<Transaction> transactions;

  const AddScreen({
    Key? key,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.transactions,
  }) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  String? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  int _currentStep = 0;
  bool _isExpense = true;

  // Mapping of categories to their image assets, located in images/ directory
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
    _dateController.text = _formatDate(_selectedDate);
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(_selectedDate);
      });
    }
  }

  Widget _buildInputField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xffC5C5C5),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildInputField(
          'Название',
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Введите название',
            ),
          ),
        ),
        const SizedBox(height: 25),
        _buildInputField(
          'Тип операции',
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Расход'),
                  selected: _isExpense,
                  onSelected: (selected) {
                    setState(() {
                      _isExpense = true;
                      _selectedCategory = null;
                      _selectedAccount = null;
                    });
                  },
                  selectedColor: const Color(0xff368983),
                  labelStyle: TextStyle(
                    color: _isExpense ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Доход'),
                  selected: !_isExpense,
                  onSelected: (selected) {
                    setState(() {
                      _isExpense = false;
                      _selectedCategory = null;
                      _selectedAccount = null;
                    });
                  },
                  selectedColor: const Color(0xff368983),
                  labelStyle: TextStyle(
                    color: !_isExpense ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final categories =
        _isExpense ? widget.expenseCategories : widget.incomeCategories;
    final accounts = AccountRepository.getAccounts();

    return Column(
      children: [
        _buildInputField(
          'Категория',
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedCategory,
            items: categories.map((category) {
              final imagePath = _categoryImages[category] ?? 'cash.png';
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'images/$imagePath',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'Failed to load category image: images/$imagePath, error: $error');
                          return const Icon(Icons.error,
                              size: 40, color: Colors.red);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            hint: const Text(
              'Выберите категорию',
              style: TextStyle(color: Colors.grey),
            ),
            underline: const SizedBox(),
          ),
        ),
        const SizedBox(height: 25),
        _buildInputField(
          'Счет',
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedAccount,
            items: accounts.map((account) {
              return DropdownMenuItem(
                value: account.name,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'images/${account.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'Failed to load account image: images/${account.image}, error: $error');
                          return const Icon(Icons.error,
                              size: 40, color: Colors.red);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      account.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedAccount = value),
            hint: const Text(
              'Выберите счет',
              style: TextStyle(color: Colors.grey),
            ),
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildInputField(
          'Сумма',
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Введите сумму',
              suffixText: '₽',
            ),
          ),
        ),
        const SizedBox(height: 25),
        _buildInputField(
          'Дата',
          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: const InputDecoration(
              border: InputBorder.none,
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            _buildBackgroundContainer(context),
            Positioned(
              top: 120,
              child: _buildFormContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 600,
      width: 340,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _isExpense ? 'Добавить расход' : 'Добавить доход',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  _saveTransaction();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
              steps: [
                Step(
                  title: const Text('Основное'),
                  content: _buildStep1(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Категория и счет'),
                  content: _buildStep2(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Сумма и дата'),
                  content: _buildStep3(),
                  isActive: _currentStep >= 2,
                ),
              ],
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep != 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(
                                color: Color(0xff368983),
                              ),
                            ),
                            child: const Text(
                              'Назад',
                              style: TextStyle(
                                color: Color(0xff368983),
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep != 0) const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff368983),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _currentStep == 2 ? 'Сохранить' : 'Далее',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveTransaction() {
    if (_titleController.text.isNotEmpty &&
        _selectedCategory != null &&
        _selectedAccount != null &&
        _amountController.text.isNotEmpty) {
      final newTransaction = Transaction(
        image: 'images/${_categoryImages[_selectedCategory] ?? 'default.png'}',
        name: _titleController.text,
        category: _selectedCategory!, // Передаем выбранную категорию
        fee: _amountController.text,
        time: _formatDate(_selectedDate),
        buy: _isExpense,
        accountName: _selectedAccount,
      );

      Navigator.of(context).pop(newTransaction);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля'),
        ),
      );
    }
  }

  Widget _buildBackgroundContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xff368983),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      _isExpense ? 'Новый расход' : 'Новый доход',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(Icons.attach_file_outlined, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
