import 'package:solo1/features/contor%20/admin/domain/entities/moderation_request_entity.dart';
import 'package:solo1/features/contor%20/admin/domain/repository/admin_repository.dart';
import '../datasource/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remote;
  AdminRepositoryImpl({AdminRemoteDataSource? remote}) : remote = remote ?? AdminRemoteDataSource();
  @override
  Future<List<ModerationRequestEntity>> incoming() async {
    final data = await remote.fetchIncoming();
    return data
        .map((e) => ModerationRequestEntity(
              id: e.id,
              agentId: e.agentId,
              title: e.title,
              createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt),
              status: e.status,
              comment: e.comment,
            ))
        .toList();
  }
  @override
  Future<void> approve(String id, {String? comment}) {
    return remote.setStatus(id, 'approved', comment: comment);
  }
  @override
  Future<void> reject(String id, {String? comment}) {
    return remote.setStatus(id, 'rejected', comment: comment);
  }
}