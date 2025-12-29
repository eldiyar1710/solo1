import '../entities/moderator_request_entity.dart';

abstract class ModeratorRepository {
  Future<List<ModeratorRequestEntity>> incoming();
  Future<void> approve(String id, {String? comment});
  Future<void> reject(String id, {String? comment});
}