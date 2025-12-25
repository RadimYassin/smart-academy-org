// Unit tests for BaseModel

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/base_model.dart';

// Concrete implementation for testing
class TestModel extends BaseModel {
  final String name;
  final int value;

  const TestModel(this.name, this.value);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

void main() {
  group('BaseModel', () {
    test('toJsonString returns valid JSON string', () {
      const model = TestModel('Test', 123);
      final jsonString = model.toJsonString();
      
      expect(jsonString, contains('"name":"Test"'));
      expect(jsonString, contains('"value":123'));
    });

    test('toString returns valid JSON string', () {
      const model = TestModel('Test', 123);
      final string = model.toString();
      
      expect(string, contains('"name":"Test"'));
      expect(string, contains('"value":123'));
    });
  });
}
