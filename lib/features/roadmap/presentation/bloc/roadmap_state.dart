import 'package:equatable/equatable.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';

/// Base state class for [RoadmapBloc].
sealed class RoadmapState extends Equatable {
  const RoadmapState();

  @override
  List<Object?> get props => [];
}

/// Initial resting state.
final class RoadmapInitial extends RoadmapState {
  const RoadmapInitial();
}

// --- Detail & Preview States ---

/// Emitted while loading a roadmap by ID.
final class RoadmapDetailLoading extends RoadmapState {
  const RoadmapDetailLoading({required this.roadmapId});

  final String roadmapId;

  @override
  List<Object?> get props => [roadmapId];
}

/// Emitted when a roadmap is loaded successfully.
final class RoadmapDetailLoaded extends RoadmapState {
  const RoadmapDetailLoaded(this.roadmap);

  final Roadmap roadmap;

  @override
  List<Object?> get props => [roadmap];
}

/// Emitted when loading a roadmap fails.
final class RoadmapDetailError extends RoadmapState {
  const RoadmapDetailError({
    required this.message,
    required this.roadmapId,
  });

  final String message;
  final String roadmapId;

  @override
  List<Object?> get props => [message, roadmapId];
}

// --- My Learning Overview States ---

/// Emitted while resolving active goals and roadmaps.
final class RoadmapOverviewLoading extends RoadmapState {
  const RoadmapOverviewLoading();
}

/// Emitted when active learning journeys are loaded.
final class RoadmapOverviewLoaded extends RoadmapState {
  const RoadmapOverviewLoaded({required this.roadmaps});

  final List<Roadmap> roadmaps;

  @override
  List<Object?> get props => [roadmaps];
}

/// Emitted when the user has no active learning roadmaps.
final class RoadmapOverviewEmpty extends RoadmapState {
  const RoadmapOverviewEmpty();
}

/// Emitted when loading the overview encounters a failure.
final class RoadmapOverviewError extends RoadmapState {
  const RoadmapOverviewError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
