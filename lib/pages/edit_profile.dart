import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_model.dart';
import 'package:flutter_application_1/data/user_repository.dart';

class EditProfile extends StatefulWidget {
  final UserModel user;

  const EditProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedAvatar;
  final List<String> _avatarOptions = [
    'avatar.png',
    'avatar1.png',
    'avatar2.png',
    'avatar3.png',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _selectedAvatar = widget.user.avatarPath.split('/').last;
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

  void _saveProfile() {
    try {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _selectedAvatar != null) {
        final updatedUser = UserModel(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatarPath: 'images/$_selectedAvatar',
        );
        UserRepository.updateUser(updatedUser);
        Navigator.of(context).pop(updatedUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, заполните все поля')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
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

  Widget _buildBackgroundContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: const BoxDecoration(
            color: Color(0xff368983),
            borderRadius: BorderRadius.only(
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
                    const Text(
                      'Редактировать профиль',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 24), // Для симметрии
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 500,
      width: 340,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Изменить данные',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildInputField(
            'Имя',
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Введите имя',
              ),
            ),
          ),
          const SizedBox(height: 25),
          _buildInputField(
            'Email',
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Введите email',
              ),
            ),
          ),
          const SizedBox(height: 25),
          _buildInputField(
            'Аватар',
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedAvatar,
              items: _avatarOptions.map((avatar) {
                return DropdownMenuItem(
                  value: avatar,
                  child: Row(
                    children: [
                      Image.asset(
                        'images/$avatar',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Failed to load avatar image: images/$avatar, error: $error');
                          return const Icon(Icons.error, size: 40);
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(avatar),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAvatar = value),
              hint: const Text('Выберите аватар'),
              underline: const SizedBox(),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff368983),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}