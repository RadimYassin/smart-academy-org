import '../../data/datasources/credit_remote_datasource.dart';
import '../../data/models/credit/credit_balance.dart';
import '../../domain/repositories/credit_repository.dart';

class CreditRepositoryImpl implements CreditRepository {
  final CreditRemoteDataSource remoteDataSource;

  CreditRepositoryImpl(this.remoteDataSource);

  @override
  Future<CreditBalance> getMyBalance() async {
    try {
      return await remoteDataSource.getMyBalance();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreditBalance> getStudentBalance(int studentId) async {
    try {
      return await remoteDataSource.getStudentBalance(studentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCredits(int studentId, double amount) async {
    try {
      await remoteDataSource.updateCredits(studentId, amount);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreditBalance> rewardLessonComplete() async {
    try {
      return await remoteDataSource.rewardLessonComplete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreditBalance> deductCredits(double amount) async {
    try {
      return await remoteDataSource.deductCredits(amount);
    } catch (e) {
      rethrow;
    }
  }
}
