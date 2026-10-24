import 'package:learno/features/home/domain/entities/home_journeys.dart';

/// Contract for accessing Home learning journey data.
abstract interface class HomeRepository {
  /// Retrieves the active journey and secondary journeys needed by Home.
  Future<HomeJourneys> getHomeJourneys();
}
