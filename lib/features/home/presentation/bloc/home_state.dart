import 'package:equatable/equatable.dart';
import 'package:learno/features/home/domain/entities/home_journeys.dart';

/// Base state class for HomeBloc.
sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial resting state before data retrieval begins.
final class HomeInitial extends HomeState {
  const HomeInitial();
}

/// State emitted while loading learning journeys.
final class HomeLoading extends HomeState {
  const HomeLoading();
}

/// State emitted when learning journeys have loaded successfully.
final class HomeLoaded extends HomeState {
  const HomeLoaded({required this.journeys});

  final HomeJourneys journeys;

  @override
  List<Object?> get props => [journeys];
}

/// State emitted when an error occurs during journey loading.
final class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
