class Transaction {
  final String image;
  final String name;
  final String category; // Новое поле для категории
  final String fee;
  final String time;
  final bool buy;
  final String? accountName;

  const Transaction({
    required this.image,
    required this.name,
    required this.category,
    required this.fee,
    required this.time,
    required this.buy,
    this.accountName,
  });
}