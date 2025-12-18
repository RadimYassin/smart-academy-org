import '../../../data/models/user/user_dto.dart';

abstract class UserRepository {
  Future<UserDto> getUserById(int userId);
  Future<UserDto> updateUser(int userId, UpdateUserRequest request);
}

