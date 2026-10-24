import 'package:learno/features/home/data/models/learning_journey_model.dart';

/// Contract for the local or mock data source supporting Home.
abstract interface class HomeLocalDataSource {
  Future<LearningJourneyModel> getActiveJourney();
  Future<List<LearningJourneyModel>> getSecondaryJourneys();
}

/// Mock implementation providing illustrative journeys for Home development.
class HomeMockDataSource implements HomeLocalDataSource {
  const HomeMockDataSource({this.delay = Duration.zero});

  final Duration delay;

  @override
  Future<LearningJourneyModel> getActiveJourney() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return const LearningJourneyModel(
      id: 'flutter-architecture',
      title: 'Flutter Production Architecture',
      description: 'Build production-ready apps with confidence.',
      completedTopics: 3,
      totalTopics: 5,
      nextTopic: 'Managing application state',
      category: 'Mobile Engineering',
      estimatedMinutesRemaining: 20,
    );
  }

  @override
  Future<List<LearningJourneyModel>> getSecondaryJourneys() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return const [
      LearningJourneyModel(
        id: 'backend-engineering',
        title: 'Backend Engineering',
        description: 'Distributed servers, robust APIs, and data modeling.',
        completedTopics: 1,
        totalTopics: 6,
        nextTopic: 'Designing REST & GraphQL APIs',
        category: 'Cloud & API',
        estimatedMinutesRemaining: 35,
      ),
      LearningJourneyModel(
        id: 'system-design',
        title: 'System Design',
        description: 'Scalability, microservices, and high-throughput systems.',
        completedTopics: 2,
        totalTopics: 4,
        nextTopic: 'Distributed Caching & CDNs',
        category: 'Architecture',
        estimatedMinutesRemaining: 15,
      ),
    ];
  }
}
