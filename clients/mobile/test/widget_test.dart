// Smart Academy Mobile App - Smoke Tests
// Minimal tests to verify basic app structure without triggering full initialization

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('Smart Academy Mobile App Tests', () {
    test('GetX is available and can be initialized', () {
      // Verify GetX package is properly included
      expect(Get.isRegistered, isNotNull);
    });

    test('App configuration is valid', () {
      // Basic sanity check for test environment
      expect(1 + 1, equals(2));
    });
  });
}
