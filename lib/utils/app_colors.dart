import 'package:flutter/material.dart';

class AppColors {
  static Color primaryColor = Colors.green;

  // one place to pick the color for a status, so task card
  // and the count boxes both use the same colors
  static Color statusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue;
      case 'Progress':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
