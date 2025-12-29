import 'package:solo1/features/main_app/home/domain/entities/agent_rank_entity.dart';
import 'package:solo1/features/main_app/home/domain/repository/home_repository.dart';

class GetLeaderboardUseCase {
  final HomeRepository repo;
  GetLeaderboardUseCase(this.repo);
  Future<List<AgentRankEntity>> call(String period) {
    return repo.getLeaderboard(period);
  }
}