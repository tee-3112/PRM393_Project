import 'package:flutter/material.dart';

class CategoryInfo {
  final int id;
  final String name;
  final bool isIncome;
  final IconData icon;

  const CategoryInfo(this.id, this.name, this.isIncome, this.icon);

  static const List<CategoryInfo> all = [
    CategoryInfo(1, 'Lương', true, Icons.work),
    CategoryInfo(2, 'Thưởng', true, Icons.card_giftcard),
    CategoryInfo(3, 'Đầu tư', true, Icons.trending_up),
    CategoryInfo(4, 'Làm thêm', true, Icons.laptop),
    CategoryInfo(5, 'Khác (Thu)', true, Icons.category),
    CategoryInfo(6, 'Ăn uống', false, Icons.restaurant),
    CategoryInfo(7, 'Quần áo', false, Icons.checkroom),
    CategoryInfo(8, 'Mỹ phẩm', false, Icons.face),
    CategoryInfo(9, 'Di chuyển', false, Icons.directions_bus),
    CategoryInfo(10, 'Nhà ở', false, Icons.home),
    CategoryInfo(11, 'Học tập', false, Icons.school),
    CategoryInfo(12, 'Giải trí', false, Icons.movie),
    CategoryInfo(13, 'Sức khỏe', false, Icons.local_hospital),
    CategoryInfo(14, 'Hóa đơn', false, Icons.receipt),
    CategoryInfo(15, 'Khác (Chi)', false, Icons.category),
  ];

  static List<CategoryInfo> get income => all.where((c) => c.isIncome).toList();
  static List<CategoryInfo> get expense => all.where((c) => !c.isIncome).toList();
  static CategoryInfo? byId(int id) {
    try { return all.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }
  static String emoji(int id) {
    const emojis = {1: '💼', 2: '🎁', 3: '📈', 4: '💻', 5: '📦', 6: '🍜', 7: '👕', 8: '💄', 9: '🚌', 10: '🏠', 11: '📚', 12: '🎬', 13: '🏥', 14: '📄', 15: '📦'};
    return emojis[id] ?? '📦';
  }
}