import 'package:flutter_application_1/data/user_model.dart';

// Список допустимых аватаров, чтобы проверять корректность путей
const _validAvatars = [
  'images/avatar.png',
  'images/avatar1.png',
  'images/avatar2.png',
  'images/avatar3.png',
  'images/cash.png',
];

/// Репозиторий для управления данными пользователя.
/// Хранит данные в памяти, с возможностью перехода к постоянному хранилищу (например, shared_preferences).
/// Предоставляет методы для инициализации, получения и обновления профиля пользователя.
class UserRepository {
  // Статическая переменная для хранения текущего пользователя
  static UserModel? _user;

  /// Инициализирует данные пользователя, если они еще не установлены.
  /// Используется при первом запуске приложения.
  static void initializeUser() {
    if (_user == null) {
      _user = UserModel(
        name: 'Иван Иванов',
        email: 'ivan@example.com',
        avatarPath: 'images/avatar.png',
      );
      // TODO: В будущем можно добавить загрузку из shared_preferences или базы данных
      // Например:
      // final prefs = await SharedPreferences.getInstance();
      // _user = UserModel(
      //   name: prefs.getString('user_name') ?? 'Иван Иванов',
      //   email: prefs.getString('user_email') ?? 'ivan@example.com',
      //   avatarPath: prefs.getString('user_avatar') ?? 'images/avatar.png',
      // );
    }
  }

  /// Возвращает текущего пользователя.
  /// Если пользователь еще не инициализирован, вызывает initializeUser().
  /// @returns [UserModel] Данные текущего пользователя.
  /// @throws Exception Если пользователь не инициализирован (маловероятно).
  static UserModel getUser() {
    if (_user == null) {
      initializeUser();
    }
    return _user!;
  }

  /// Обновляет данные пользователя.
  /// Проверяет корректность входных данных (имя, email, аватар).
  /// @param updatedUser Новый объект [UserModel] с обновленными данными.
  /// @throws ArgumentError Если данные некорректны (например, пустое имя, неверный email, недопустимый аватар).
  static void updateUser(UserModel updatedUser) {
    // Валидация имени
    if (updatedUser.name.trim().isEmpty) {
      throw ArgumentError('Имя пользователя не может быть пустым');
    }

    // Валидация email
    if (!_isValidEmail(updatedUser.email)) {
      throw ArgumentError('Некорректный формат email');
    }

    // Валидация пути к аватару
    if (!_validAvatars.contains(updatedUser.avatarPath)) {
      throw ArgumentError(
          'Недопустимый путь к аватару: ${updatedUser.avatarPath}');
    }

    // Обновление данных
    _user = updatedUser;

    // TODO: В будущем можно добавить сохранение в shared_preferences или базу данных
    // Например:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('user_name', updatedUser.name);
    // await prefs.setString('user_email', updatedUser.email);
    // await prefs.setString('user_avatar', updatedUser.avatarPath);
  }

  /// Проверяет корректность формата email.
  /// @param email Строка для проверки.
  /// @returns [bool] true, если email валиден, иначе false.
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Сбрасывает данные пользователя до начальных значений.
  /// Может использоваться для выхода из аккаунта или тестирования.
  static void resetUser() {
    _user = null;
    initializeUser();
  }
}
