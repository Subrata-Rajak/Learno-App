import 'package:learno/features/home/domain/entities/home_journeys.dart';
import 'package:learno/features/home/domain/repositories/home_repository.dart';

/// Use case that fetches journeys required to render the Home screen.
class GetHomeJourneys {
  const GetHomeJourneys(this.repository);

  final HomeRepository repository;

  Future<HomeJourneys> call() async {
    return repository.getHomeJourneys();
  }
}
