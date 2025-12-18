import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get width => mediaQuery.size.width;
  double get height => mediaQuery.size.height;

  bool get isDarkMode => theme.brightness == Brightness.dark;
}

extension DateTimeExtension on DateTime {
  String toFormattedString({String format = 'yyyy-MM-dd'}) {
    // Simple date formatting
    String year = this.year.toString();
    String month = this.month.toString().padLeft(2, '0');
    String day = this.day.toString().padLeft(2, '0');

    return format
        .replaceAll('yyyy', year)
        .replaceAll('MM', month)
        .replaceAll('dd', day);
  }
}
