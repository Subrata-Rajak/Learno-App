import 'package:learno/features/home/data/datasources/home_local_datasource.dart';
import 'package:learno/features/home/domain/entities/home_journeys.dart';
import 'package:learno/features/home/domain/repositories/home_repository.dart';

/// Implementation of HomeRepository querying HomeLocalDataSource.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.dataSource});

  final HomeLocalDataSource dataSource;

  @override
  Future<HomeJourneys> getHomeJourneys() async {
    try {
      final active = await dataSource.getActiveJourney();
      final secondary = await dataSource.getSecondaryJourneys();
      return HomeJourneys(activeJourney: active, secondaryJourneys: secondary);
    } catch (e) {
      throw Exception('Failed to load home journeys: $e');
    }
  }
}
