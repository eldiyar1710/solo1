import '../repository/moderator_repository.dart';

class RejectModeratorRequestUseCase {
  final ModeratorRepository repo;
  RejectModeratorRequestUseCase(this.repo);
  Future<void> call(String id, {String? comment}) => repo.reject(id, comment: comment);
}