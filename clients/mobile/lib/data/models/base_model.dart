import 'dart:convert';

abstract class BaseModel {
  const BaseModel();

  Map<String, dynamic> toJson();
  
  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  String toString() => toJsonString();
}

