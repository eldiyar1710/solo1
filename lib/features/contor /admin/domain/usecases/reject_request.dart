import '../repository/admin_repository.dart';

class RejectRequestUseCase {
  final AdminRepository repo;
  RejectRequestUseCase(this.repo);
  Future<void> call(String id, {String? comment}) => repo.reject(id, comment: comment);
}