import '../entities/moderation_request_entity.dart';
import '../repository/admin_repository.dart';

class GetIncomingRequestsUseCase {
  final AdminRepository repo;
  GetIncomingRequestsUseCase(this.repo);
  Future<List<ModerationRequestEntity>> call() => repo.incoming();
}