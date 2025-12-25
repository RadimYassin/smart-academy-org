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
    return CreditBalance(
      userId: json['userId'] as int,
      balance: (json['balance'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CreditBalance(userId: $userId, balance: $balance, lastUpdated: $lastUpdated)';
  }
}

class UpdateCreditRequest {
  final int studentId;
  final double amount;

  UpdateCreditRequest({
    required this.studentId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'amount': amount,
    };
  }
}

class DeductCreditRequest {
  final double amount;

  DeductCreditRequest({required this.amount});

  Map<String, dynamic> toJson() {
    return {'amount': amount};
  }
}
