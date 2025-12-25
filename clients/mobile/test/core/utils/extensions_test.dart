// Unit tests for String, DateTime, and BuildContext extensions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/extensions.dart';

void main() {
  group('StringExtension', () {
    group('capitalize', () {
      test('capitalizes first letter of lowercase string', () {
        expect('hello'.capitalize(), equals('Hello'));
      });

      test('keeps already capitalized string unchanged', () {
        expect('Hello'.capitalize(), equals('Hello'));
      });

      test('returns empty string for empty input', () {
        expect(''.capitalize(), equals(''));
      });

      test('capitalizes single character', () {
        expect('a'.capitalize(), equals('A'));
      });

      test('keeps uppercase string unchanged', () {
        expect('HELLO'.capitalize(), equals('HELLO'));
      });
    });

    group('toTitleCase', () {
      test('converts all words to title case', () {
        expect('hello world'.toTitleCase(), equals('Hello World'));
      });

      test('handles multiple spaces between words', () {
        expect('hello  world'.toTitleCase(), equals('Hello  World'));
      });

      test('returns empty string for empty input', () {
        expect(''.toTitleCase(), equals(''));
      });

      test('handles single word', () {
        expect('hello'.toTitleCase(), equals('Hello'));
      });

      test('handles already title cased string', () {
        expect('Hello World'.toTitleCase(), equals('Hello World'));
      });

      test('handles mixed case strings', () {
        expect('hELLo WoRLd'.toTitleCase(), equals('HELLo WoRLd'));
      });
    });
  });

  group('DateTimeExtension', () {
    group('toFormattedString', () {
      test('formats date with default format (yyyy-MM-dd)', () {
        final date = DateTime(2024, 3, 15);
        expect(date.toFormattedString(), equals('2024-03-15'));
      });

      test('formats date with custom format', () {
        final date = DateTime(2024, 3, 15);
        expect(date.toFormattedString(format: 'dd/MM/yyyy'), equals('15/03/2024'));
      });

      test('pads single digit month and day with zeros', () {
        final date = DateTime(2024, 1, 5);
        expect(date.toFormattedString(), equals('2024-01-05'));
      });

      test('handles year correctly', () {
        final date = DateTime(2025, 12, 31);
        expect(date.toFormattedString(), equals('2025-12-31'));
      });

      test('formats date with partial format string', () {
        final date = DateTime(2024, 3, 15);
        expect(date.toFormattedString(format: 'yyyy/MM'), equals('2024/03'));
      });
    });
  });

  group('BuildContextExtension', () {
    testWidgets('provides access to theme data', (WidgetTester tester) async {
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      expect(capturedContext, isNotNull);
      expect(capturedContext!.theme, isA<ThemeData>());
      expect(capturedContext!.textTheme, isA<TextTheme>());
      expect(capturedContext!.colorScheme, isA<ColorScheme>());
    });

    testWidgets('provides access to media query data', (WidgetTester tester) async {
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      expect(capturedContext!.mediaQuery, isA<MediaQueryData>());
      expect(capturedContext!.width, isA<double>());
      expect(capturedContext!.height, isA<double>());
      expect(capturedContext!.width, greaterThan(0));
      expect(capturedContext!.height, greaterThan(0));
    });

    testWidgets('correctly identifies dark mode', (WidgetTester tester) async {
      BuildContext? lightContext;
      BuildContext? darkContext;

      // Test light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              lightContext = context;
              return Container();
            },
          ),
        ),
      );

      expect(lightContext!.isDarkMode, isFalse);

      // Test dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              darkContext = context;
              return Container();
            },
          ),
        ),
      );

      expect(darkContext!.isDarkMode, isTrue);
    });
  });
}
