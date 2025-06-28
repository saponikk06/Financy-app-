import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/account_model.dart';

class AccountRepository {
  static final List<Account> _accounts = [];

  static List<Account> getAccounts() {
    return List<Account>.from(_accounts);
  }

  static void addAccount(Account account) {
    _accounts.add(account);
  }

  static void updateAccount(String name, Account updatedAccount) {
    final index = _accounts.indexWhere((account) => account.name == name);
    if (index != -1) {
      _accounts[index] = updatedAccount;
    }
  }

  static void clearAccounts() {
    _accounts.clear();
  }
}
