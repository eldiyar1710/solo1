import '../repository/moderator_repository.dart';

class ApproveModeratorRequestUseCase {
  final ModeratorRepository repo;
  ApproveModeratorRequestUseCase(this.repo);
  Future<void> call(String id, {String? comment}) => repo.approve(id, comment: comment);
}