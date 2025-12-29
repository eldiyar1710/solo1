import 'package:solo1/features/main_app/home/domain/entities/home_banner.dart';
import 'package:solo1/features/main_app/home/domain/repository/home_repository.dart';

class FetchHomeBanners {
  final HomeRepository repo;
  FetchHomeBanners(this.repo);
  Future<List<HomeBanner>> call() => repo.getBanners();
}