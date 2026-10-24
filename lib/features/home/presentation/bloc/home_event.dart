import 'package:equatable/equatable.dart';

/// Base event class for HomeBloc.
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the Home screen requests to load learning journeys.
final class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}
