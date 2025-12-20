class CreditBalance {
  final int userId;
  final double balance;
  final DateTime lastUpdated;

  CreditBalance({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });

  factory CreditBalance.fromJson(Map<String, dynamic> json) {
    // Handle userId - can be int or Long (from Java)
    int userIdValue;
    if (json['userId'] is int) {
      userIdValue = json['userId'] as int;
    } else if (json['userId'] is num) {
      userIdValue = (json['userId'] as num).toInt();
    } else {
      userIdValue = int.parse(json['userId'].toString());
    }

    // Handle balance - BigDecimal from Java can be number or string
    double balanceValue;
    if (json['balance'] is num) {
      balanceValue = (json['balance'] as num).toDouble();
    } else if (json['balance'] is String) {
      balanceValue = double.parse(json['balance'] as String);
    } else {
      balanceValue = double.parse(json['balance'].toString());
    }

    // Handle lastUpdated - LocalDateTime from Java
    DateTime lastUpdatedValue;
    if (json['lastUpdated'] is String) {
      lastUpdatedValue = DateTime.parse(json['lastUpdated'] as String);
    } else if (json['lastUpdated'] is List) {
      // Handle LocalDateTime as array [year, month, day, hour, minute, second, nanosecond]
      final dateArray = json['lastUpdated'] as List;
      lastUpdatedValue = DateTime(
        dateArray[0] as int,
        dateArray[1] as int,
        dateArray[2] as int,
        dateArray.length > 3 ? dateArray[3] as int : 0,
        dateArray.length > 4 ? dateArray[4] as int : 0,
        dateArray.length > 5 ? dateArray[5] as int : 0,
      );
    } else {
      // Try to parse as ISO string
      lastUpdatedValue = DateTime.parse(json['lastUpdated'].toString());
    }

    return CreditBalance(
      userId: userIdValue,
      balance: balanceValue,
      lastUpdated: lastUpdatedValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

