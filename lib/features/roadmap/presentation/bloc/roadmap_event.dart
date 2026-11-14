import 'package:equatable/equatable.dart';

/// Base event class for [RoadmapBloc].
sealed class RoadmapEvent extends Equatable {
  const RoadmapEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load a specific roadmap by ID.
class RoadmapDetailRequested extends RoadmapEvent {
  const RoadmapDetailRequested(this.roadmapId);

  final String roadmapId;

  @override
  List<Object?> get props => [roadmapId];
}

/// Dispatched to load active learning goals and resolve their roadmaps for My Learning.
class RoadmapOverviewRequested extends RoadmapEvent {
  const RoadmapOverviewRequested();
}
