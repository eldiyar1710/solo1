import 'package:solo1/features/main_app/home/domain/entities/home_notification_entity.dart';
import 'package:solo1/features/main_app/home/domain/repository/home_repository.dart';

class GetNotificationsUseCase {
  final HomeRepository repo;
  GetNotificationsUseCase(this.repo);
  Future<List<HomeNotificationEntity>> call() {
    return repo.getNotifications();
  }
}