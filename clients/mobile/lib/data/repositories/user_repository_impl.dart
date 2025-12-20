import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user/user_dto.dart';
import '../models/user/credit_balance.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserDto> getUserById(int userId) async {
    return await remoteDataSource.getUserById(userId);
  }

  @override
  Future<UserDto> updateUser(int userId, UpdateUserRequest request) async {
    return await remoteDataSource.updateUser(userId, request);
  }

  @override
  Future<CreditBalance> getCreditBalance() async {
    return await remoteDataSource.getCreditBalance();
  }

  @override
  Future<CreditBalance> rewardLessonComplete() async {
    return await remoteDataSource.rewardLessonComplete();
  }

  @override
  Future<CreditBalance> deductCredits(double amount) async {
    return await remoteDataSource.deductCredits(amount);
  }
}

