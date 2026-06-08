enum TransactionType { income, expense }

class Transaction {
  final int id;
  final int userId;
  final TransactionType type;
  final double amount;
  final int categoryId;
  final String categoryName;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    this.description,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['userId'] as int? ?? 1,
      type: json['type'] as String == 'income' ? TransactionType.income : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      description: json['description'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type == TransactionType.income ? 'income' : 'expense',
    'amount': amount,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'description': description,
    'date': date.toIso8601String().split('T')[0],
    'createdAt': createdAt.toIso8601String(),
  };

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
}