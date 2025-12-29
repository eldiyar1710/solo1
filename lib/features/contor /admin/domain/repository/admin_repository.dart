import '../entities/moderation_request_entity.dart';

abstract class AdminRepository {
  Future<List<ModerationRequestEntity>> incoming();
  Future<void> approve(String id, {String? comment});
  Future<void> reject(String id, {String? comment});
}