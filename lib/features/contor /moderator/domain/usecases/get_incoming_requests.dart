import '../entities/moderator_request_entity.dart';
import '../repository/moderator_repository.dart';

class GetIncomingModeratorRequestsUseCase {
  final ModeratorRepository repo;
  GetIncomingModeratorRequestsUseCase(this.repo);
  Future<List<ModeratorRequestEntity>> call() => repo.incoming();
}