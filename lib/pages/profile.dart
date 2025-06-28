import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/transaction_repository.dart';
import 'package:flutter_application_1/data/user_model.dart';
import 'package:flutter_application_1/data/user_repository.dart';
import 'package:flutter_application_1/pages/edit_profile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isDarkMode = false; // Переключатель темного режима
  late UserModel _user;
  int _transactionCount = 0;

  @override
  void initState() {
    super.initState();
    UserRepository.initializeUser(); // Инициализация пользователя
    _user = UserRepository.getUser();
    _transactionCount = TransactionRepository.getTransactions().length;
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.of(context).push<UserModel>(
      MaterialPageRoute(
        builder: (context) => EditProfile(user: _user),
      ),
    );
    if (updatedUser != null) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  void _logout() {
    UserRepository.resetUser();
    setState(() {
      _user = UserRepository.getUser();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Вы вышли из аккаунта')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Профиль',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Карточка пользователя
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              _user.avatarPath,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Failed to load avatar image: ${_user.avatarPath}, error: $error');
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _user.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Статистика
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          const Text(
                            'Статистика',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Всего транзакций',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$_transactionCount',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff368983),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Настройки
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          const Text(
                            'Настройки',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SwitchListTile(
                            title: const Text(
                              'Темный режим',
                              style: TextStyle(fontSize: 16),
                            ),
                            value: _isDarkMode,
                            activeColor: const Color(0xff368983),
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                                // Здесь можно добавить логику смены темы
                              });
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Редактировать профиль',
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: const Icon(
                              Icons.edit,
                              color: Color(0xff368983),
                            ),
                            onTap: _navigateToEditProfile,
                          ),
                          ListTile(
                            title: const Text(
                              'Выйти',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}