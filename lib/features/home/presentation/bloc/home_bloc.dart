import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learno/features/home/domain/usecases/get_home_journeys.dart';
import 'package:learno/features/home/presentation/bloc/home_event.dart';
import 'package:learno/features/home/presentation/bloc/home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

/// Presentation state coordinator for the Home feature.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.getHomeJourneys}) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onHomeLoadRequested);
  }

  final GetHomeJourneys getHomeJourneys;

  Future<void> _onHomeLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final journeys = await getHomeJourneys();
      emit(HomeLoaded(journeys: journeys));
    } catch (e) {
      emit(
        const HomeError(
          message:
              'Unable to load your learning journeys. Please check your connection and try again.',
        ),
      );
    }
  }
}
