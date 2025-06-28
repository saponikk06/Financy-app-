import 'package:flutter_application_1/data/transaction_model.dart';
import 'package:flutter_application_1/data/account_repository.dart';
import 'package:flutter_application_1/data/account_model.dart';

class TransactionRepository {
  static List<Transaction> _transactions = [];

  static List<Transaction> getTransactions() {
    return _transactions;
  }

  static void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    // Update the account balance if an account is specified
    if (transaction.accountName != null) {
      final amount = double.tryParse(transaction.fee) ?? 0;
      final accounts = AccountRepository.getAccounts();
      final account = accounts.firstWhere(
        (acc) => acc.name == transaction.accountName,
        orElse: () => Account(
          name: '',
          type: 'Неизвестный', // Provide a default type
          balance: '0',
          image: 'default.png',
        ),
      );
      if (account.name.isNotEmpty) {
        final currentBalance = double.tryParse(account.balance) ?? 0;
        final newBalance = transaction.buy
            ? currentBalance - amount
            : currentBalance + amount;
        final updatedAccount = Account(
          name: account.name,
          type: account.type, // Preserve the original type
          balance: newBalance.toStringAsFixed(2),
          image: account.image,
        );
        AccountRepository.updateAccount(account.name, updatedAccount);
      }
    }
  }
}