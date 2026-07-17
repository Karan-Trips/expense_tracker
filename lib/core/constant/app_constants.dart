import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  shopping,
  travel,
  utilities,
  entertainment,
  others
}

class AppConstants {
  static const String appName = "AuraExpense";
  
  static String getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.others:
        return 'Others';
    }
  }

  static IconData getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.travel:
        return Icons.directions_car;
      case ExpenseCategory.utilities:
        return Icons.receipt_long;
      case ExpenseCategory.entertainment:
        return Icons.sports_esports;
      case ExpenseCategory.others:
        return Icons.more_horiz;
    }
  }

  static Color getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return const Color(0xFFFF5252); // Coral/Red
      case ExpenseCategory.shopping:
        return const Color(0xFFFFEB3B); // Yellow
      case ExpenseCategory.travel:
        return const Color(0xFF00E676); // Emerald Green
      case ExpenseCategory.utilities:
        return const Color(0xFF29B6F6); // Sky Blue
      case ExpenseCategory.entertainment:
        return const Color(0xFFAB47BC); // Purple
      case ExpenseCategory.others:
        return const Color(0xFF90A4AE); // Grey-Blue
    }
  }
}
