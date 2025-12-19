import '../../../data/models/user/user_dto.dart';
import '../../../data/models/user/credit_balance.dart';

abstract class UserRepository {
  Future<UserDto> getUserById(int userId);
  Future<UserDto> updateUser(int userId, UpdateUserRequest request);
  Future<CreditBalance> getCreditBalance();
  Future<CreditBalance> rewardLessonComplete();
  Future<CreditBalance> deductCredits(double amount);
}

