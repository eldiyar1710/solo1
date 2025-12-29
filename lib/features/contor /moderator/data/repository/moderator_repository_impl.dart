import 'package:solo1/features/contor%20/moderator/domain/entities/moderator_request_entity.dart';
import 'package:solo1/features/contor%20/moderator/domain/repository/moderator_repository.dart';
import '../datasource/moderator_remote_datasource.dart';

class ModeratorRepositoryImpl implements ModeratorRepository {
  final ModeratorRemoteDataSource remote;
  ModeratorRepositoryImpl({ModeratorRemoteDataSource? remote}) : remote = remote ?? ModeratorRemoteDataSource();
  @override
  Future<List<ModeratorRequestEntity>> incoming() async {
    final data = await remote.fetchIncoming();
    return data
        .map((e) => ModeratorRequestEntity(
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