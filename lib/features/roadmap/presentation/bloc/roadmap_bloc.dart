import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/domain/usecases/get_active_learning_goals.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_by_goal.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_event.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_state.dart';

/// BLoC orchestrating single-roadmap presentation and My Learning overview resolution.
class RoadmapBloc extends Bloc<RoadmapEvent, RoadmapState> {
  RoadmapBloc({
    required this.getRoadmap,
    required this.getRoadmapByGoal,
    required this.getActiveLearningGoals,
  }) : super(const RoadmapInitial()) {
    on<RoadmapDetailRequested>(_onDetailRequested);
    on<RoadmapOverviewRequested>(_onOverviewRequested);
  }

  final GetRoadmap getRoadmap;
  final GetRoadmapByGoal getRoadmapByGoal;
  final GetActiveLearningGoals getActiveLearningGoals;

  Future<void> _onDetailRequested(
    RoadmapDetailRequested event,
    Emitter<RoadmapState> emit,
  ) async {
    final trimmedId = event.roadmapId.trim();
    if (trimmedId.isEmpty) {
      emit(
        const RoadmapDetailError(
          message: 'Invalid roadmap ID.',
          roadmapId: '',
        ),
      );
      return;
    }

    emit(RoadmapDetailLoading(roadmapId: trimmedId));

    try {
      final roadmap = await getRoadmap(trimmedId);
      emit(RoadmapDetailLoaded(roadmap));
    } catch (e) {
      emit(
        RoadmapDetailError(
          message: _mapErrorToMessage(e),
          roadmapId: trimmedId,
        ),
      );
    }
  }

  Future<void> _onOverviewRequested(
    RoadmapOverviewRequested event,
    Emitter<RoadmapState> emit,
  ) async {
    emit(const RoadmapOverviewLoading());

    try {
      final goals = await getActiveLearningGoals();

      if (goals.isEmpty) {
        emit(const RoadmapOverviewEmpty());
        return;
      }

      final List<Roadmap> resolvedRoadmaps = [];

      for (final goal in goals) {
        try {
          final roadmap = await getRoadmapByGoal(goal.id);
          resolvedRoadmaps.add(roadmap);
        } catch (_) {
          // If a goal has no roadmap yet (404), skip gracefully without failing the entire list
          continue;
        }
      }

      if (resolvedRoadmaps.isEmpty) {
        emit(const RoadmapOverviewEmpty());
      } else {
        emit(RoadmapOverviewLoaded(roadmaps: resolvedRoadmaps));
      }
    } catch (e) {
      emit(RoadmapOverviewError(message: _mapErrorToMessage(e)));
    }
  }

  String _mapErrorToMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
