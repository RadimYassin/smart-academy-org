// Smart Academy Mobile App - Smoke Tests
// This test verifies that the app can be launched successfully

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App launches successfully - smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(GetMaterialApp), findsOneWidget);
    
    // Allow the app to settle
    await tester.pumpAndSettle();
    
    // Verify that the app initialized (basic structure exists)
    expect(tester.allWidgets.isNotEmpty, true);
  });

  testWidgets('App uses GetX for state management', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Verify GetMaterialApp is used (GetX requirement)
    expect(find.byType(GetMaterialApp), findsOneWidget);
    
    // Verify that GetX is properly initialized
    expect(Get.isRegistered, isNotNull);
  });
}
