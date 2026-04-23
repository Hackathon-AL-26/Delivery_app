part of 'journey_bloc.dart';

enum JourneyBlocStatus { initial, loading, loaded, error }

final class JourneyState {
  final JourneyBlocStatus status;
  final Journey? journey;
  final String? errorMessage;

  const JourneyState({
    this.status = JourneyBlocStatus.initial,
    this.journey,
    this.errorMessage,
  });

  JourneyState copyWith({
    JourneyBlocStatus? status,
    Journey? journey,
    bool clearJourney = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return JourneyState(
      status: status ?? this.status,
      journey: clearJourney ? null : (journey ?? this.journey),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
