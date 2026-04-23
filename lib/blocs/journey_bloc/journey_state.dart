part of 'journey_bloc.dart';

enum JourneyBlocStatus { initial, loading, loaded, error }

final class JourneyState {
  final JourneyBlocStatus status;
  final List<Journey> journeys;

  JourneyState({
    this.status = JourneyBlocStatus.initial,
    this.journeys = const [],
  });

  JourneyState copyWith({
    JourneyBlocStatus? status,
    List<Journey>? journeys,
  }) {
    return JourneyState(
      status: status ?? this.status,
      journeys: journeys ?? this.journeys,
    );
  }
}
