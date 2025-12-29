import '../repository/admin_repository.dart';

class ApproveRequestUseCase {
  final AdminRepository repo;
  ApproveRequestUseCase(this.repo);
  Future<void> call(String id, {String? comment}) => repo.approve(id, comment: comment);
}