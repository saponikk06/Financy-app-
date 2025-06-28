class Account {
  final String name;
  final String type; // e.g., Card, Cash, Bank Account
  final String balance; // Stored as string for display (e.g., "1000.00")
  final String image; // Image asset path

  const Account({
    required this.name,
    required this.type,
    required this.balance,
    required this.image,
  });
}