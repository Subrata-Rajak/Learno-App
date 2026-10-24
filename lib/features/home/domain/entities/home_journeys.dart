import 'package:equatable/equatable.dart';
import 'package:learno/features/home/domain/entities/learning_journey.dart';

/// Aggregation of journeys displayed on the Home screen.
class HomeJourneys extends Equatable {
  const HomeJourneys({
    required this.activeJourney,
    required this.secondaryJourneys,
  });

  final LearningJourney activeJourney;
  final List<LearningJourney> secondaryJourneys;

  @override
  List<Object?> get props => [activeJourney, secondaryJourneys];
}
