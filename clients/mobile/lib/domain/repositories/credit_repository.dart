import '../models/credit/credit_balance.dart';

abstract class CreditRepository {
  /// Get current user's credit balance
  Future<CreditBalance> getMyBalance();

  /// Get student credit balance (Teacher/Admin only)
  Future<CreditBalance> getStudentBalance(int studentId);

  /// Update student credits (Teacher/Admin only)
  /// Use positive amounts to add, negative to deduct
  Future<void> updateCredits(int studentId, double amount);

  /// Reward credits for completing a lesson
  /// Automatically adds 5 credits
  Future<CreditBalance> rewardLessonComplete();

  /// Deduct credits from current user's account
  /// Used for quiz retries, premium features, etc.
  Future<CreditBalance> deductCredits(double amount);
}
