class Budget {
  final int id;
  final int userId;
  final int categoryId;
  final String categoryName;
  final int month;
  final int year;
  final double amount;
  final double spentAmount;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.month,
    required this.year,
    required this.amount,
    this.spentAmount = 0,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int,
      userId: json['userId'] as int? ?? 1,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      month: json['month'] as int,
      year: json['year'] as int,
      amount: (json['amount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'month': month,
    'year': year,
    'amount': amount,
    'spentAmount': spentAmount,
  };

  double get usagePercent => amount > 0 ? (spentAmount / amount) * 100 : 0;
  double get remainingAmount => amount - spentAmount;
  double get remainingPercent => amount > 0 ? ((amount - spentAmount) / amount) * 100 : 0;
  bool get isWarning => usagePercent >= 90;
}